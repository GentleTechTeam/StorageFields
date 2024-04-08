import 'package:googleapis/firestore/v1.dart';
import 'package:storage_fields/src/firestore_implementation/utils/index.dart';

class DocumentQuery {
  final List<String> collectionIds;
  final List<DocumentFilter> filters;
  final int? limit;
  final DocumentSort? sort;

  const DocumentQuery({
    required this.collectionIds,
    required this.filters,
    this.limit,
    this.sort,
  });

  RunQueryRequest generateQuery() {
    final sortValue = sort;

    return RunQueryRequest(
      structuredQuery: StructuredQuery(
        from: [
          for (final collectionId in collectionIds)
            CollectionSelector(collectionId: collectionId),
        ],
        where: _createFilters(filters),
        limit: limit,
        orderBy: sortValue != null ? [sortValue.toFirebaseOrder()] : null,
      ),
    );
  }

  Filter? _createFilters(List<DocumentFilter> filters) {
    if (filters.isEmpty) {
      return null;
    }

    if (filters.length == 1) {
      return filters.first.toFirebaseFilter();
    }

    return Filter(
      compositeFilter: CompositeFilter(
        op: 'AND',
        filters: filters.map((filter) => filter.toFirebaseFilter()).toList(),
      ),
    );
  }
}

class DocumentFilter {
  final String fieldName;
  // ignore: no-object-declaration
  final Object fieldValue;
  final FieldValueMatcherType fieldValueMatcherType;

  const DocumentFilter({
    required this.fieldName,
    required this.fieldValue,
    required this.fieldValueMatcherType,
  });

  Filter toFirebaseFilter() {
    return Filter(
      fieldFilter: FieldFilter(
        field: FieldReference(
          fieldPath: fieldName,
        ),
        op: fieldValueMatcherType.toFirestoreOp(),
        value: Value.fromJson(
          fieldValue.toEncodedMap(),
        ),
      ),
    );
  }
}

class DocumentSort {
  final DocumentSortDirection direction;
  final String fieldPath;

  const DocumentSort({
    required this.direction,
    required this.fieldPath,
  });

  Order toFirebaseOrder() {
    return Order(
      direction: direction._firebaseSortDirection,
      field: FieldReference(fieldPath: fieldPath),
    );
  }
}

enum DocumentSortDirection {
  ascending('ASCENDING'),
  unspecified('DIRECTION_UNSPECIFIED'),
  descending('DESCENDING');

  final String _firebaseSortDirection;

  const DocumentSortDirection(this._firebaseSortDirection);
}
