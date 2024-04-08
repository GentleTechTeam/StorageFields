import 'package:storage_fields/src/models/index.dart';

class StorageFieldValueWithMeta<SFValue> {
  final SFValue? value;
  final StorageFieldMeta meta;

  const StorageFieldValueWithMeta({
    required this.value,
    required this.meta,
  });

  factory StorageFieldValueWithMeta.fromStorageField(
    StorageField sf,
    SFValue? Function(Object? json) fromJsonValueConverter,
  ) =>
      StorageFieldValueWithMeta(
        value: fromJsonValueConverter(sf.value),
        meta: StorageFieldMeta.fromStorageField(sf),
      );
}
