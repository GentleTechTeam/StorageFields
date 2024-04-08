import 'package:storage_fields/src/models/index.dart';

abstract class StorageFieldsService {
  Future<void> write({
    required StorageField data,
  });

  Future<StorageField?> getField({
    required String fieldCode,
    DateTime? dateGroupKey,
    DateTime? changedSince,
  });

  Future<StorageField?> getLastAvailableField({
    required String fieldCode,
    required DateTime toDate,
    DateTime? changedSince,
  });
}
