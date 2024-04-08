// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_field.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StorageField _$StorageFieldFromJson(Map<String, dynamic> json) =>
    StorageField._(
      code: json['code'] as String,
      value: json['value'],
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      dirty: json['dirty'] as bool,
      dateGroupKey: json['dateGroupKey'] == null
          ? null
          : DateTime.parse(json['dateGroupKey'] as String),
    );

Map<String, dynamic> _$StorageFieldToJson(StorageField instance) =>
    <String, dynamic>{
      'code': instance.code,
      'value': instance.value,
      'dateGroupKey': toJsonUntouched(instance.dateGroupKey),
      'updatedAt': toJsonUntouched(instance.updatedAt),
      'dirty': instance.dirty,
    };
