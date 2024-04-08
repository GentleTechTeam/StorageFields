import 'package:collection/collection.dart';
import 'package:json_annotation/src/json_converter.dart';
import 'package:storage_fields/storage_fields.dart';

import 'primary_field_wrapper_example.dart';

class UserIsOldWrapper
    extends SecondaryStorageFieldWrapper<bool, DependencyResolveResult1<int?>> {
  @override
  final StorageFieldsService storageFieldsService;
  final UserAgeWrapper userAgeWrapper;

  UserIsOldWrapper({
    required this.storageFieldsService,
    required this.userAgeWrapper,
  });

  @override
  String get fieldCode => 'user_is_old';

  /// Valid for day means that the value of the secondary field is valid for the day.
  @override
  SecondaryFieldValidityParams get validityParams =>
      SecondaryFieldValidityParams.validForDay();

  @override
  JsonConverter<bool, Object?> get valueConverter => throw BoolValueConverter();

  /// Define the dependencies for the secondary field
  @override
  DependencyResolver<DependencyResolveResult1<int?>> get dependencyResolver =>
      DependencyResolver1(
        dep1: DependencyItem(
          fieldWrapper: userAgeWrapper,

          /// In our case its depends on the user age field. Becuase the validity params of secondary field is valid for day
          /// we request userAge for the particular date
          onGetFieldDates: (params) => [params.date],
        ),
      );

  /// Resolve all dependencies and calculate the value of the secondary field
  @override
  bool calculate(DependencyResolveResult1<int?> resolveResult) {
    final userAge = resolveResult.item1.firstOrNull;

    return userAge != null && userAge > 30;
  }
}

class BoolValueConverter implements JsonConverter<bool?, Object?> {
  ///
  /// The `defaultValue` by default is `null`
  /// But its value can be set whenever the preferred behavior is not return a `null`
  /// in cases that there is no value stored on the storage field
  final bool? defaultValue;
  const BoolValueConverter({
    this.defaultValue,
  });

  @override
  bool? fromJson(Object? json) {
    if (json is! bool) {
      return defaultValue;
    }

    return json;
  }

  @override
  bool? toJson(bool? value) {
    return value;
  }
}
