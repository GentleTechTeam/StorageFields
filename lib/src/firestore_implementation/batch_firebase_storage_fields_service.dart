import 'package:collection/collection.dart';
import 'package:storage_fields/src/firestore_implementation/index.dart';
import 'package:storage_fields/src/models/index.dart';
import 'package:storage_fields/src/services/index.dart';

class BatchFirebaseStorageFieldsService implements BatchStorageFieldsService {
  final FirestoreService firestoreService;
  final BaseConfigurationService baseConfigurationService;

  final StorageFieldsPathUtils _storageFieldsPathUtils;

  BatchFirebaseStorageFieldsService({
    required this.firestoreService,
    required this.baseConfigurationService,
  }) : _storageFieldsPathUtils = StorageFieldsPathUtils(
          firestoreDocumentsPath:
              baseConfigurationService.firestoreDocumentsPath,
        );

  @override
  Future<List<StorageField>> batchGetStorageFields(
    Iterable<GetStorageFieldParams> storageFieldsParams,
  ) async {
    final documentNames = storageFieldsParams
        .map(
          (params) => _storageFieldsPathUtils.createDocumentPath(
            fieldId: StorageField.createId(
              name: params.fieldCode,
              dateGroupKey: params.dateGroupKey,
            ),
          ),
        )
        .toList();

    final resultDocuments = await firestoreService.batchGetDocuments(
      documentNames,
      baseConfigurationService.firestoreDatabasePath,
    );

    if (resultDocuments == null) {
      return [];
    }

    return resultDocuments
        .whereNotNull()
        .map(StorageFieldsFirebaseExtension.fromFirebaseDocument)
        .toList();
  }

  /// TODO: Implement this method
  @override
  Future<void> batchWriteStorageFields(
    Iterable<StorageField> properties,
  ) async {
    return;
  }
}
