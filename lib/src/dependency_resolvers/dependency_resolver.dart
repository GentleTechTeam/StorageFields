import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:storage_fields/src/dependency_resolvers/index.dart';
import 'package:storage_fields/src/models/index.dart';
import 'package:storage_fields/src/models/on_get_field_dates_params.dart';
import 'package:storage_fields/src/utils/index.dart';
import 'package:storage_fields/src/wrappers/index.dart';

abstract class DependencyResolver<T extends DependencyResolveResult> {
  List<DependencyItem<Object?>> get dependencies;

  T mapDependencyValuesToResult(List<List<Object?>> values);

  /// TODO: Refactor to split the logic
  // ignore: long-method, long-parameter-list
  Future<ResolveResult<T>> resolve({
    DateTime? date,
    DateTime? baseDate,
    DateTime? changedSince,
    bool Function(
      int depItemIndex,
      int dateIndex,
      StorageFieldWrapper<Object?> dependencyWrapper,
      DateTime? targetDate,
    )?
        shouldResolve,
  }) async {
    final resolvedDepsCollection =
        await Future.wait<List<_ResolvedValueForDate<Object?>>>(
      dependencies.mapIndexed((depItemIndex, dependencyItem) async {
        final onGetFieldDatesResult = date != null
            ? dependencyItem.onGetFieldDates.call(
                OnGetFieldDatesParams(date: date, baseDate: baseDate),
              )
            : <DateTime>[];
        if (onGetFieldDatesResult == null) {
          return <_ResolvedValueForDate<Object?>>[];
        }

        if (date == null || onGetFieldDatesResult.isEmpty) {
          final shouldResolveItem = shouldResolve?.call(
                depItemIndex,
                0,
                dependencyItem.fieldWrapper,
                date,
              ) ??
              true;
          if (!shouldResolveItem) {
            return <_ResolvedValueForDate<Object?>>[];
          }

          final valueWithMeta =
              await dependencyItem.fieldWrapper.getWithMetaInternal(
            date: date,
            changedSince: changedSince,
          );

          return [
            _ResolvedValueForDate(
              depItemIndex: depItemIndex,
              dateIndex: 0,
              valueWithMeta: valueWithMeta,
            ),
          ];
        }

        return Future.wait<_ResolvedValueForDate<Object?>>(
          onGetFieldDatesResult.mapIndexed(
            (dateIndex, date) async {
              final shouldResolveItem = shouldResolve?.call(
                    depItemIndex,
                    dateIndex,
                    dependencyItem.fieldWrapper,
                    date,
                  ) ??
                  true;
              if (!shouldResolveItem) {
                return Future.value(
                  _ResolvedValueForDate(
                    depItemIndex: depItemIndex,
                    dateIndex: dateIndex,
                    valueWithMeta: null,
                  ),
                );
              }

              final valueWithMeta =
                  await dependencyItem.fieldWrapper.getWithMetaInternal(
                date: date,
                changedSince: changedSince,
              );

              return _ResolvedValueForDate(
                depItemIndex: depItemIndex,
                dateIndex: dateIndex,
                valueWithMeta: valueWithMeta,
              );
            },
          ),
        );
      }),
    );

    final values = List<List<Object?>>.generate(
      dependencies.length,
      (_) => <Object?>[],
    );
    // ignore: prefer-correct-identifier-length
    final depItemIndexToDateIndexesOfResolvedDeps = <int, Set<int>>{};
    DateTime? maxDepUpdatedAt;

    for (final resolvedDep in resolvedDepsCollection) {
      for (final resolvedValueForDate in resolvedDep) {
        if (resolvedValueForDate.valueWithMeta == null) {
          values[resolvedValueForDate.depItemIndex].add(null);

          continue;
        }

        depItemIndexToDateIndexesOfResolvedDeps.update(
          resolvedValueForDate.depItemIndex,
          (value) => value..add(resolvedValueForDate.dateIndex),
          ifAbsent: () => {resolvedValueForDate.dateIndex},
        );

        values[resolvedValueForDate.depItemIndex]
            .add(resolvedValueForDate.valueWithMeta?.value);

        final updatedAt = resolvedValueForDate.valueWithMeta?.meta.updatedAt;
        maxDepUpdatedAt = updatedAt?.max(maxDepUpdatedAt) ?? maxDepUpdatedAt;
      }
    }

    return ResolveResult<T>(
      result: mapDependencyValuesToResult(values),
      maxDepUpdatedAt: maxDepUpdatedAt,
      depItemIndexToDateIndexesOfResolvedDeps:
          depItemIndexToDateIndexesOfResolvedDeps,
    );
  }
}

class _ResolvedValueForDate<T> {
  final int depItemIndex;
  final int dateIndex;
  final StorageFieldValueWithMeta<T>? valueWithMeta;

  const _ResolvedValueForDate({
    required this.depItemIndex,
    required this.dateIndex,
    required this.valueWithMeta,
  });
}

@internal
class ResolveResult<T extends DependencyResolveResult> {
  final T result;
  final DateTime? maxDepUpdatedAt;

  final Map<int, Set<int>> _depItemIndexToDateIndexesOfResolvedDeps;

  const ResolveResult({
    required this.result,
    required this.maxDepUpdatedAt,
    required Map<int, Set<int>> depItemIndexToDateIndexesOfResolvedDeps,
  }) : _depItemIndexToDateIndexesOfResolvedDeps =
            depItemIndexToDateIndexesOfResolvedDeps;

  bool get nothingWasResolved =>
      _depItemIndexToDateIndexesOfResolvedDeps.isEmpty;

  bool isDepMissing({
    required int depItemIndex,
    required int dateIndex,
  }) =>
      !(_depItemIndexToDateIndexesOfResolvedDeps[depItemIndex] ?? const {})
          .contains(dateIndex);

  ResolveResult<T> merge(
    ResolveResult<T> other,
  ) {
    return ResolveResult(
      result: result.merge(other.result) as T,
      maxDepUpdatedAt:
          maxDepUpdatedAt?.max(other.maxDepUpdatedAt) ?? other.maxDepUpdatedAt,
      depItemIndexToDateIndexesOfResolvedDeps:
          _depItemIndexToDateIndexesOfResolvedDeps
              .merge(other._depItemIndexToDateIndexesOfResolvedDeps),
    );
  }
}

extension _MapExtension<T> on Map<T, Set<int>> {
  Map<T, Set<int>> merge(Map<T, Set<int>> other) {
    return {
      ...this,
      for (final entry in other.entries)
        entry.key: ((this[entry.key] ?? {})..addAll(entry.value)),
    };
  }
}
