import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:storage_fields/src/utils/index.dart';

part 'storage_field.g.dart';

@JsonSerializable(constructor: '_')
class StorageField extends Equatable {
  @JsonKey(name: StorageFieldKeys.code)
  final String code;
  @JsonKey(name: StorageFieldKeys.value)
  // ignore: no-object-declaration
  final Object? value;
  @JsonKey(toJson: toJsonUntouched, name: StorageFieldKeys.dateGroupKey)
  final DateTime? dateGroupKey;
  @JsonKey(toJson: toJsonUntouched, name: StorageFieldKeys.updatedAt)
  final DateTime updatedAt;
  @JsonKey(name: StorageFieldKeys.dirty)
  final bool dirty;

  const StorageField._({
    required this.code,
    required this.value,
    required this.updatedAt,
    required this.dirty,
    this.dateGroupKey,
  });

  factory StorageField.create({
    required String code,
    required Object? value,
    required DateTime? dateGroupKey,
    required DateTime updatedAt,
    required bool dirty,
  }) {
    return StorageField._(
      code: code,
      value: value,
      updatedAt: updatedAt,
      dateGroupKey: dateGroupKey,
      dirty: dirty,
    );
  }

  factory StorageField.fromJson(Map<String, dynamic> json) =>
      _$StorageFieldFromJson(json);

  static String createId({
    required String name,
    DateTime? dateGroupKey,
  }) {
    if (dateGroupKey == null) {
      return name;
    }

    final dateKey = !dateGroupKey.containsTimeInfo
        ? DateFormat('yyyy-MM-dd').format(dateGroupKey)
        : dateGroupKey.toIso8601String();

    return '${name}_$dateKey';
  }

  Map<String, Object?> toJsonWithMeta() {
    return <String, Object?>{
      ..._$StorageFieldToJson(this),
    };
  }

  String get id {
    return createId(
      name: code,
      dateGroupKey: dateGroupKey,
    );
  }

  @override
  List<Object?> get props => [
        code,
        value,
        dateGroupKey,
        dirty,
      ];
}

Object? toJsonUntouched(Object? value) => value;

abstract class StorageFieldKeys {
  static const String code = 'code';
  static const String value = 'value';
  static const String dateGroupKey = 'dateGroupKey';
  static const String updatedAt = 'updatedAt';
  static const String dirty = 'dirty';
}
