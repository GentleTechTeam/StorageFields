import 'package:storage_fields/src/models/index.dart';

/// Service to provide methods to execute batch operations
/// for storage fields.
abstract class BatchStorageFieldsService {
  Future<List<StorageField>> batchGetStorageFields(
    Iterable<GetStorageFieldParams> storageFieldsParams,
  );

  Future<void> batchWriteStorageFields(
    Iterable<StorageField> fields,
  );
}
