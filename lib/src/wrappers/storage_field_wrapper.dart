import 'dart:async';

import 'package:intl/locale.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:storage_fields/src/dependency_resolvers/index.dart';
import 'package:storage_fields/src/models/index.dart';
import 'package:storage_fields/src/services/index.dart';
import 'package:storage_fields/src/utils/index.dart';
import 'package:storage_fields/src/value_formatters/index.dart';

abstract class StorageFieldWrapper<SFValue> {
  String get fieldCode;
  JsonConverter<SFValue?, Object?> get valueConverter;
  StorageFieldsService get storageFieldsService;
  FieldValidityParams get validityParams;

  String getValueLabel({
    required SFValue value,
    Locale? locale,
  }) {
    return SFValueFormatter.fromValue(value).format(locale: locale);
  }

  Future<void> set({
    required SFValue value,
    DateTime? date,
  });

  /// When calling the SF getter we can optionally pass a [date].
  /// If [date] is not specified, then current date will be used to get the data.
  /// F.e. to get field for current week, pass any date of current week (from monday to sunday)
  Future<SFValue?> get({
    DateTime? date,
  }) async {
    final valueWithMeta = await getWithMeta(date: date);

    return valueWithMeta?.value;
  }

  Future<StorageFieldValueWithMeta<SFValue>?> getWithMeta({
    DateTime? date,
  }) =>
      getWithMetaInternal(date: date);

  /// Created to hide [changedSince] param from other libs usage.
  /// Use [getWithMeta] instead
  @internal
  Future<StorageFieldValueWithMeta<SFValue>?> getWithMetaInternal({
    DateTime? date,
    DateTime? changedSince,
  });

  // ignore: long-parameter-list
  Future<StorageField?> _setInternal({
    required SFValue value,
    DateTime? date,
    DateTime? updatedAt,
  }) async {
    final validityType = validityParams.validityType;
    final targetDate = date ?? validityType.defaultDate;
    if (validityType.dateGroupKeyRequired && targetDate == null) {
      print(
        '[Set SF] Date should be provided for "$fieldCode" field with $validityType validity type.\n'
        'This indicates potential error. Nothing will be set for this field',
      );

      return null;
    }

    final field = _createFieldInternal(
      value: value,
      date: targetDate,
      updatedAt: updatedAt,
    );

    await storageFieldsService.write(data: field);

    return field;
  }

  StorageField _createFieldInternal({
    required SFValue value,
    DateTime? date,
    DateTime? updatedAt,
  }) {
    return StorageField.create(
      code: fieldCode,
      value: valueConverter.toJson(value),
      dateGroupKey: date != null
          ? validityParams.dateGroup?.createDateGroupKey(date)
          : null,
      updatedAt: updatedAt ?? DateTime.now().toUtc(),
      dirty: false,
    );
  }

  // ignore: long-parameter-list
  Future<StorageFieldValueWithMeta<SFValue>?> _getEntityFromRepositoryInternal({
    DateTime? date,
    DateTime? changedSince,
  }) async {
    final StorageField? rawSfEntity;
    switch (validityParams.validityType) {
      // For field that do not change dateGroupKey should be empty,
      // because there should be just one item with same field code in collection
      case ValueValidityType.alwaysValid:
        rawSfEntity = await storageFieldsService.getField(
          fieldCode: fieldCode,
          changedSince: changedSince,
        );
        break;
      // If we don't have a value for target date and the type is “time series”
      // the getter must return null. (dateGroupKey will be used as filter to handle that)
      case ValueValidityType.validForCertainDateGroup:
        final targetDate = date ?? DateTime.now();
        rawSfEntity = await storageFieldsService.getField(
          fieldCode: fieldCode,
          dateGroupKey:
              // ignore: avoid-non-null-assertion
              validityParams.dateGroup!.createDateGroupKey(
            targetDate,
          ),
          changedSince: changedSince,
        );
        break;
      // If the getter can't find a value for the date provided
      // and this SF type is “Last Available” it will retrieve
      // from the last version available before that.
      case ValueValidityType.lastIsValid:
        rawSfEntity = await storageFieldsService.getLastAvailableField(
          fieldCode: fieldCode,
          // ignore: avoid-non-null-assertion
          toDate: validityParams.dateGroup!.createDateGroupKey(
            date ?? DateTime.now().toUtc(),
          ),
          changedSince: changedSince,
        );
        break;
    }

    if (rawSfEntity == null) {
      return null;
    }

    return StorageFieldValueWithMeta<SFValue>.fromStorageField(
      rawSfEntity,
      valueConverter.fromJson,
    );
  }
}

abstract class PrimaryStorageFieldWrapper<SFValue>
    extends StorageFieldWrapper<SFValue> {
  @override
  PrimaryFieldValidityParams get validityParams;

  @override
  Future<void> set({
    required SFValue value,
    DateTime? date,
  }) async {
    await _setInternal(
      value: value,
      date: date,
    );
  }

  @override
  @internal
  Future<StorageFieldValueWithMeta<SFValue>?> getWithMetaInternal({
    DateTime? date,
    DateTime? changedSince,
  }) async {
    return _getEntityFromRepositoryInternal(
      date: date,
      changedSince: changedSince,
    );
  }
}

abstract class SecondaryStorageFieldWrapper<SFValue,
        DResolveResult extends DependencyResolveResult>
    extends StorageFieldWrapper<SFValue> {
  DependencyResolver<DResolveResult> get dependencyResolver;
  @override
  SecondaryFieldValidityParams get validityParams;
  StorageFieldWrapper<DateTime?>? get baseDateDependency => null;

  SFValue calculate(DResolveResult resolveResult);

  @override
  Future<void> set({
    required SFValue value,
    DateTime? date,
    // ignore: no-empty-block
  }) async {
    // Do nothing for secondary fields
  }

  @override
  @internal
  // ignore: long-method
  Future<StorageFieldValueWithMeta<SFValue>?> getWithMetaInternal({
    DateTime? date,
    DateTime? changedSince,
  }) async {
    final dateGroup = validityParams.dateGroup;
    final validityType = validityParams.validityType;
    final dateIsRequiredButNotProvided =
        dateGroup != null && validityType.dateGroupKeyRequired && date == null;
    if (dateIsRequiredButNotProvided) {
      print(
        '[Get Secondary SF] Date should be provided for "$fieldCode" field with $validityType validity type.\n'
        'This indicates potential error. Nothing will be calculated for this field',
      );

      return null;
    }

    final baseDate = await _resolveBaseDate(date: date);
    final deps = await dependencyResolver.resolve(
      date: date,
      baseDate: baseDate?.value,
      shouldResolve: (
        depItemIndex,
        dateIndex,
        dependencyWrapper,
        targetDate,
      ) {
        final isCircularDep = dependencyWrapper == this && targetDate == date;

        return !isCircularDep;
      },
    );

    final value = calculate(deps.result);
    final updatedAt = baseDate?.meta.updatedAt.max(
      deps.maxDepUpdatedAt,
    );

    /// Skip waiting for field being set
    unawaited(
      _setInternal(
        value: value,
        date: date,
        updatedAt: updatedAt,
      ),
    );

    return StorageFieldValueWithMeta.fromStorageField(
      _createFieldInternal(
        value: value,
        date: date ?? validityType.defaultDate,
        updatedAt: updatedAt,
      ),
      valueConverter.fromJson,
    );
  }

  FutureOr<StorageFieldValueWithMeta<DateTime?>?> _resolveBaseDate({
    DateTime? date,
    DateTime? changedSince,
  }) async {
    final baseDateSfWrapper = baseDateDependency;
    if (baseDateSfWrapper == null) {
      return null;
    }

    return await baseDateSfWrapper.getWithMetaInternal(
      date: date,
      changedSince: changedSince,
    );
  }
}

abstract class ForwardingStorageFieldWrapper<SFValue>
    extends StorageFieldWrapper<SFValue> {
  @override
  ForwardingFieldValidityParams get validityParams;

  @protected
  Future<SFValue?> resolve({
    DateTime? date,
  });

  @override
  Future<void> set({
    required SFValue value,
    DateTime? date,
    // ignore: no-empty-block
  }) async {
    // Do nothing for forwarding properties
  }

  /// Default implementation is suitable for fields that proxy values
  /// to the external api. Override if needed.
  /// Created to hide [changedSince] param from other libs usage.
  /// Use [getWithMeta] instead
  @override
  @internal
  Future<StorageFieldValueWithMeta<SFValue>?> getWithMetaInternal({
    DateTime? date,
    DateTime? changedSince,
  }) async {
    final dateGroup = validityParams.dateGroup;
    final validityType = validityParams.validityType;
    if (dateGroup != null &&
        validityType.dateGroupKeyRequired &&
        date == null) {
      return null;
    }

    final value = await resolve(date: date);
    if (value == null) {
      return null;
    }

    return StorageFieldValueWithMeta(
      value: value,
      meta: StorageFieldMeta(updatedAt: DateTime.now().toUtc()),
    );
  }
}
