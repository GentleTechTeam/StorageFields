import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:storage_fields/src/models/index.dart';
import 'package:storage_fields/src/services/index.dart';

/// Service, which handles call to methods in a "batching" manner and caches results
/// to reduce external API calls and improve performance
///
/// Warning: Do not forget to call [dispose] when you are done with using this service
class BatchingCachingStorageFieldsService implements StorageFieldsService {
  final _SFMethodsCache _methodsCache;
  final _BatchingExecutor<StorageField, void> _writeFieldBatchingExecutor;
  final _BatchingExecutor<_GetFieldPayload, StorageField?>
      _getFieldBatchingExecutor;
  final _BatchingExecutor<_GetLastAvailableFieldPayload, StorageField?>
      _getLastAvailableFieldBatchingExecutor;

  BatchingCachingStorageFieldsService._({
    required _BatchingExecutor<StorageField, void> writeFieldBatchingExecutor,
    required _BatchingExecutor<_GetFieldPayload, StorageField?>
        getFieldBatchingExecutor,
    required _BatchingExecutor<_GetLastAvailableFieldPayload, StorageField?>
        getLastAvailableFieldBatchingExecutor,
  })  : _methodsCache = _SFMethodsCache(),
        _writeFieldBatchingExecutor = writeFieldBatchingExecutor,
        _getFieldBatchingExecutor = getFieldBatchingExecutor,
        _getLastAvailableFieldBatchingExecutor =
            getLastAvailableFieldBatchingExecutor;

  factory BatchingCachingStorageFieldsService.fromServices({
    required StorageFieldsService storageFieldsService,
    required BatchStorageFieldsService batchStorageFieldsService,
  }) {
    return BatchingCachingStorageFieldsService._(
      writeFieldBatchingExecutor: _BatchingExecutor(
        executorHandler: (batchedPayloads) {
          return Future.wait(
            batchedPayloads.map(
              (payload) => storageFieldsService.write(data: payload),
            ),
          );
        },
      ),
      getFieldBatchingExecutor: _createGetFieldBatchingExecutor(
        storageFieldsService: storageFieldsService,
        batchStorageFieldsService: batchStorageFieldsService,
      ),
      getLastAvailableFieldBatchingExecutor: _BatchingExecutor(
        executorHandler: (batchedPayloads) {
          return Future.wait(
            batchedPayloads.map(
              (payload) => storageFieldsService.getLastAvailableField(
                fieldCode: payload.fieldCode,
                toDate: payload.toDate,
                changedSince: payload.changedSince,
              ),
            ),
          );
        },
      ),
    );
  }

  void dispose() {
    _writeFieldBatchingExecutor.dispose();
    _getFieldBatchingExecutor.dispose();
    _getLastAvailableFieldBatchingExecutor.dispose();
  }

  @override
  Future<void> write({required StorageField data}) async {
    final key = data.props.join('_');

    if (_methodsCache.contains(key)) {
      return;
    }

    _methodsCache.add(cacheKey: key, field: data);
    final params = _ExecutorHandlerParams(
      payload: data,
      key: key,
    );
    await _writeFieldBatchingExecutor.run(params: params);
  }

  @override
  Future<StorageField?> getField({
    required String fieldCode,
    DateTime? dateGroupKey,
    DateTime? changedSince,
  }) async {
    final key = '${fieldCode}_${dateGroupKey}_$changedSince';
    if (_methodsCache.contains(key)) {
      return _methodsCache.get(key);
    }

    final params = _ExecutorHandlerParams(
      payload: _GetFieldPayload(
        fieldCode: fieldCode,
        dateGroupKey: dateGroupKey,
        changedSince: changedSince,
      ),
      key: key,
    );
    final result = await _getFieldBatchingExecutor.run(params: params);
    _methodsCache.add(cacheKey: key, field: result);

    return result;
  }

  @override
  Future<StorageField?> getLastAvailableField({
    required String fieldCode,
    required DateTime toDate,
    DateTime? changedSince,
  }) async {
    final key = '${fieldCode}_${toDate}_$changedSince';
    if (_methodsCache.contains(key)) {
      return _methodsCache.get(key);
    }

    final params = _ExecutorHandlerParams(
      payload: _GetLastAvailableFieldPayload(
        fieldCode: fieldCode,
        toDate: toDate,
        changedSince: changedSince,
      ),
      key: key,
    );
    final result = await _getLastAvailableFieldBatchingExecutor.run(
      params: params,
    );
    _methodsCache.add(cacheKey: key, field: result);

    return result;
  }

  static _BatchingExecutor<_GetFieldPayload, StorageField?>
      _createGetFieldBatchingExecutor({
    required StorageFieldsService storageFieldsService,
    required BatchStorageFieldsService batchStorageFieldsService,
  }) {
    return _BatchingExecutor(
      executorHandler: (batchedPayloads) async {
        final groupedPayloads = _GetFieldGroupedPayloads.fromPayloads(
          batchedPayloads,
        );

        final fieldsWithChangedSinceFilterFuture = Future.wait(
          groupedPayloads.payloadsWithChangedSinceFilter.map(
            (payload) => storageFieldsService.getField(
              fieldCode: payload.fieldCode,
              dateGroupKey: payload.dateGroupKey,
              changedSince: payload.changedSince,
            ),
          ),
        );

        final otherFieldsFuture =
            batchStorageFieldsService.batchGetStorageFields(
          groupedPayloads.payloads.map(
            (payload) => GetStorageFieldParams(
              fieldCode: payload.fieldCode,
              dateGroupKey: payload.dateGroupKey,
            ),
          ),
        );

        final resolvedFields = await Future.wait(
          [fieldsWithChangedSinceFilterFuture, otherFieldsFuture],
        );

        final fieldsGroupedByIds = resolvedFields.flattened
            .fold<Map<String, StorageField?>>({}, (result, field) {
          final resolvedFieldId = field?.id;
          if (resolvedFieldId == null) {
            return result;
          }

          result[resolvedFieldId] = field;

          return result;
        });

        /// Ensure that fields are returned in the same order as they were requested
        /// Because underlying batching service may return them in different order
        /// and drop some values if they are null
        return batchedPayloads.map((payload) {
          final fieldId = StorageField.createId(
            name: payload.fieldCode,
            dateGroupKey: payload.dateGroupKey,
          );

          return fieldsGroupedByIds[fieldId];
        });
      },
    );
  }
}

class _SFMethodsCache {
  final Map<String, StorageField?> _fieldsByCacheKey = {};

  void add({
    required String cacheKey,
    required StorageField? field,
  }) {
    _fieldsByCacheKey[cacheKey] = field;
  }

  StorageField? get(String cacheKey) {
    return _fieldsByCacheKey[cacheKey];
  }

  bool contains(String cacheKey) {
    return _fieldsByCacheKey.containsKey(cacheKey);
  }
}

/// [P] is params payload type.
/// [R] is result type
/// Combines multiple requests with same params into a batch,
/// and then executes them.
///
/// Warning: Do not forget to call [dispose] when you are done with getting data
class _BatchingExecutor<P, R> {
  static const _bufferTime = Duration(milliseconds: 10);

  final _ExecutorHandler<P, R> _executorHandler;

  final _paramsController =
      StreamController<_ExecutorHandlerParams<P>>.broadcast();
  final _resultsSubject = BehaviorSubject<
      List<_BatchedResultWithParams<_ExecutorHandlerParams<P>, R>>>.seeded([]);
  final _pendingRequestsSubject = BehaviorSubject<int>.seeded(0);

  StreamSubscription<void>? _requestParamsSubscription;

  _BatchingExecutor({
    required _ExecutorHandler<P, R> executorHandler,
  }) : _executorHandler = executorHandler;

  Future<R> run({
    required _ExecutorHandlerParams<P> params,
  }) async {
    _pendingRequestsSubject.add(_pendingRequestsSubject.value + 1);
    _requestParamsSubscription ??= _startRequestsBatching();
    _paramsController.add(params);

    final targetResult = await _listenToTargetResult(params);
    _pendingRequestsSubject.add(_pendingRequestsSubject.value - 1);
    _cleanUpIfNeeded();

    return targetResult;
  }

  void dispose() async {
    await _pendingRequestsSubject.where((count) => count == 0).first;
    _requestParamsSubscription?.cancel();
    _resultsSubject.close();
    _paramsController.close();
    _pendingRequestsSubject.close();
  }

  StreamSubscription<void> _startRequestsBatching() {
    return _paramsController.stream
        .bufferTime(_bufferTime)
        .where((collectedParams) => collectedParams.isNotEmpty)
        .listen(
      (collectedParams) async {
        final uniqueParams = collectedParams.toSet();

        final results = await _executorHandler(
          uniqueParams.map((params) => params.payload),
        );

        _resultsSubject.add([
          ..._resultsSubject.value,
          ...results.mapIndexed((index, result) {
            final params = uniqueParams.elementAt(index);

            return _BatchedResultWithParams(params: params, result: result);
          }),
        ]);
      },
    );
  }

  Future<R> _listenToTargetResult(
    _ExecutorHandlerParams<P> params,
  ) async {
    return _resultsSubject
        .map(
          (resultsWithParams) {
            // Find the result that matches params
            return resultsWithParams.firstWhereOrNull(
              (resultWithParams) => resultWithParams.params == params,
            );
          },
        )
        .whereNotNull()
        .map((resultWithParams) => resultWithParams.result)
        .first;
  }

  /// Clean up if there are no more pending requests
  void _cleanUpIfNeeded() {
    if (_resultsSubject.hasListener || _requestParamsSubscription == null) {
      return;
    }

    _requestParamsSubscription?.cancel();
    _requestParamsSubscription = null;
    _resultsSubject.add([]);
  }
}

typedef _ExecutorHandler<P, R> = Future<Iterable<R>> Function(
  Iterable<P> payloads,
);

class _ExecutorHandlerParams<P> extends Equatable {
  final P payload;
  final String key;

  const _ExecutorHandlerParams({
    required this.payload,
    required this.key,
  });

  @override
  List<Object?> get props => [key];
}

class _BatchedResultWithParams<P, R> {
  final P params;
  final R result;

  _BatchedResultWithParams({
    required this.params,
    required this.result,
  });
}

class _GetFieldPayload {
  final String fieldCode;
  final DateTime? dateGroupKey;
  final DateTime? changedSince;

  const _GetFieldPayload({
    required this.fieldCode,
    required this.dateGroupKey,
    required this.changedSince,
  });
}

class _GetLastAvailableFieldPayload {
  final String fieldCode;
  final DateTime toDate;
  final DateTime? changedSince;

  const _GetLastAvailableFieldPayload({
    required this.fieldCode,
    required this.toDate,
    required this.changedSince,
  });
}

class _GetFieldGroupedPayloads {
  final List<_GetFieldPayload> payloads;
  final List<_GetFieldPayload> payloadsWithChangedSinceFilter;

  const _GetFieldGroupedPayloads({
    required this.payloads,
    required this.payloadsWithChangedSinceFilter,
  });

  factory _GetFieldGroupedPayloads.fromPayloads(
    Iterable<_GetFieldPayload> source,
  ) {
    final payloads = <_GetFieldPayload>[];
    final payloadsWithChangedSinceFilter = <_GetFieldPayload>[];

    for (final payload in source) {
      if (payload.changedSince == null) {
        payloads.add(payload);
      } else {
        payloadsWithChangedSinceFilter.add(payload);
      }
    }

    return _GetFieldGroupedPayloads(
      payloads: payloads,
      payloadsWithChangedSinceFilter: payloadsWithChangedSinceFilter,
    );
  }
}
