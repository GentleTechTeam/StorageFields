class StorageFieldsPathUtils {
  final String firestoreDocumentsPath;

  static const _collectionName = 'storageFields';

  const StorageFieldsPathUtils({
    required this.firestoreDocumentsPath,
  });

  String get collectionName => _collectionName;

  String createDocumentPath({
    required String fieldId,
  }) {
    return '$collectionName/$fieldId';
  }

  String createHistoryDocumentPath({
    required String fieldId,
  }) {
    // ignore: prefer_utc_dates
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    return '$collectionName/$fieldId/history/${fieldId}_$timestamp';
  }
}
