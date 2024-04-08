import 'package:googleapis/firestore/v1.dart';
import 'package:storage_fields/src/firestore_implementation/index.dart';
import 'package:storage_fields/src/firestore_implementation/utils/index.dart';
import 'package:storage_fields/src/models/index.dart';
import 'package:storage_fields/src/services/index.dart';
import 'package:storage_fields/src/utils/index.dart';

class FirebaseStorageFieldsService implements StorageFieldsService {
  final FirestoreService firestoreService;
  final BaseConfigurationService baseConfigurationService;
  final StorageFieldsPathUtils _storageFieldsPathUtils;

  FirebaseStorageFieldsService({
    required this.firestoreService,
    required this.baseConfigurationService,
  }) : _storageFieldsPathUtils = StorageFieldsPathUtils(
          firestoreDocumentsPath:
              baseConfigurationService.firestoreDocumentsPath,
        );

  @override
  Future<void> write({
    required StorageField data,
  }) async {
    final currentFieldData = await getField(
      fieldCode: data.code,
      dateGroupKey: data.dateGroupKey,
    );

    if (currentFieldData != data) {
      final document = data.toFirebaseDocumentWithMeta();
      await firestoreService.updateFromDocument(
        document: document,
        name: _storageFieldsPathUtils.createDocumentPath(
          fieldId: data.id,
        ),
      );

      await firestoreService.updateFromDocument(
        document: document,
        name: _storageFieldsPathUtils.createHistoryDocumentPath(
          fieldId: data.id,
        ),
      );
    }
  }

  @override
  Future<StorageField?> getField({
    required String fieldCode,
    DateTime? dateGroupKey,
    DateTime? changedSince,
  }) async {
    if (changedSince == null) {
      final document = await firestoreService.getDocument(
        name: _storageFieldsPathUtils.createDocumentPath(
          fieldId: StorageField.createId(
            name: fieldCode,
            dateGroupKey: dateGroupKey,
          ),
        ),
      );

      return document == null
          ? null
          : StorageFieldsFirebaseExtension.fromFirebaseDocument(document);
    }

    final fields = await firestoreService.queryDocuments(
      parent: _storageFieldsPathUtils.collectionName,
      documentQuery: DocumentQuery(
        collectionIds: [_storageFieldsPathUtils.collectionName],
        filters: [
          DocumentFilter(
            fieldName: StorageFieldKeys.code,
            fieldValue: fieldCode,
            fieldValueMatcherType: FieldValueMatcherType.equal,
          ),
          if (dateGroupKey != null)
            DocumentFilter(
              fieldName: StorageFieldKeys.dateGroupKey,
              fieldValue: dateGroupKey,
              fieldValueMatcherType: FieldValueMatcherType.equal,
            ),
          DocumentFilter(
            fieldName: StorageFieldKeys.updatedAt,
            fieldValue: changedSince,
            fieldValueMatcherType: FieldValueMatcherType.greaterThan,
          ),
        ],
        // Should not be needed because we filter by dateGroupKey, but just in case
        limit: 1,
      ),
    );
    if (fields.isEmpty) {
      return null;
    }

    return StorageFieldsFirebaseExtension.fromFirebaseDocument(fields.first);
  }

  @override
  Future<StorageField?> getLastAvailableField({
    required String fieldCode,
    required DateTime toDate,
    DateTime? changedSince,
  }) async {
    final fields = await firestoreService.queryDocuments(
      parent: _storageFieldsPathUtils.collectionName,
      documentQuery: DocumentQuery(
        collectionIds: [_storageFieldsPathUtils.collectionName],
        filters: [
          DocumentFilter(
            fieldName: StorageFieldKeys.code,
            fieldValue: fieldCode,
            fieldValueMatcherType: FieldValueMatcherType.equal,
          ),
          DocumentFilter(
            fieldName: StorageFieldKeys.dateGroupKey,
            fieldValue: toDate,
            fieldValueMatcherType: FieldValueMatcherType.lessThanOrEqual,
          ),
        ],
        limit: 1,
        sort: const DocumentSort(
          fieldPath: StorageFieldKeys.dateGroupKey,
          direction: DocumentSortDirection.descending,
        ),
      ),
    );

    if (fields.isEmpty) {
      return null;
    }

    final entity =
        StorageFieldsFirebaseExtension.fromFirebaseDocument(fields.first);

    if (changedSince != null && entity.updatedAt.isSameOrBefore(changedSince)) {
      return null;
    }

    return entity;
  }
}

extension StorageFieldsFirebaseExtension on StorageField {
  static StorageField fromFirebaseDocument(Document document) {
    final documentData = document.toDecodedJson();

    return StorageField.fromJson(documentData);
  }

  Document toFirebaseDocumentWithMeta() {
    return Document.fromJson(
      toJsonWithMeta().toFirestoreJson(),
    );
  }
}
