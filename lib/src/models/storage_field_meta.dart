import 'package:storage_fields/src/models/index.dart';

class StorageFieldMeta {
  final DateTime updatedAt;

  const StorageFieldMeta({
    required this.updatedAt,
  });

  factory StorageFieldMeta.fromStorageField(StorageField sf) {
    return StorageFieldMeta(
      updatedAt: sf.updatedAt,
    );
  }
}
