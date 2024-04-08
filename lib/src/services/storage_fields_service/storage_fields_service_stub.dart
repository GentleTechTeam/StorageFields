import 'package:collection/collection.dart';
import 'package:storage_fields/src/models/index.dart';
import 'package:storage_fields/src/services/index.dart';
import 'package:storage_fields/src/utils/index.dart';
import 'package:storage_fields/src/wrappers/index.dart';

/// Should mimic [FirebaseStorageFieldsService] behavior
/// Do not forget to update this stub if [FirebaseStorageFieldsService] approach is changed

class StorageFieldsServiceStub implements StorageFieldsService {
  final diagnostics = _SFDiagnosticTool();

  final Map<String, StorageField> _fields = {};

  @override
  Future<void> write({
    required StorageField data,
  }) async {
    _fields[data.id] = data;

    diagnostics.addWriteLog(
      fieldCode: data.code,
      dateGroupKey: data.dateGroupKey,
    );
  }

  @override
  Future<StorageField?> getField({
    required String fieldCode,
    DateTime? dateGroupKey,
    DateTime? changedSince,
  }) async {
    final field = _fields.values.firstWhereOrNull(
      (element) =>
          element.code == fieldCode &&
          (element.dateGroupKey == dateGroupKey) &&
          (changedSince == null || element.updatedAt.isAfter(changedSince)),
    );

    if (field != null) {
      diagnostics.addReadLog(
        fieldCode: fieldCode,
        dateGroupKey: field.dateGroupKey,
      );
    }

    return field;
  }

  @override
  Future<StorageField?> getLastAvailableField({
    required String fieldCode,
    required DateTime toDate,
    DateTime? changedSince,
  }) async {
    final fieldCandidate = _fields.values
        .where((element) => element.dateGroupKey != null)
        // ignore: avoid-non-null-assertion
        .sortedBy<DateTime>((element) => element.dateGroupKey!)
        .lastWhereOrNull(
      (element) {
        final dateGroupKey = element.dateGroupKey;
        if (dateGroupKey == null) {
          return false;
        }

        return element.code == fieldCode && dateGroupKey.isSameOrBefore(toDate);
      },
    );

    if (fieldCandidate == null) {
      return null;
    }

    diagnostics.addReadLog(
      fieldCode: fieldCode,
      dateGroupKey: fieldCandidate.dateGroupKey,
    );

    if (changedSince != null &&
        fieldCandidate.updatedAt.isSameOrBefore(changedSince)) {
      return null;
    }

    return fieldCandidate;
  }

  void reset() {
    _fields.clear();
    diagnostics.reset();
  }
}

class _SFDiagnosticTool {
  final Map<String, _SFDiagnosticTrack> _tracks = {};

  int get reads => _tracks.values.map((track) => track.reads).sum;

  int get writes => _tracks.values.map((track) => track.writes).sum;

  int get interactions => _tracks.values.map((track) => track.interactions).sum;

  int getReadsPerField({
    required StorageFieldWrapper<Object?> wrapper,
    required DateTime? targetDate,
  }) {
    final targetTrack = _tracks[wrapper.fieldCode];
    if (targetTrack == null) {
      return 0;
    }

    final fieldDateGroup = wrapper.validityParams.dateGroup;
    final fieldDateGroupKey = targetDate == null
        ? null
        : fieldDateGroup?.createDateGroupKey(targetDate);

    return targetTrack.getReadsPerDateGroup(fieldDateGroupKey);
  }

  int getWritesPerField({
    required StorageFieldWrapper<Object?> wrapper,
    required DateTime? targetDate,
  }) {
    final targetTrack = _tracks[wrapper.fieldCode];
    if (targetTrack == null) {
      return 0;
    }

    final fieldDateGroup = wrapper.validityParams.dateGroup;
    final fieldDateGroupKey = targetDate == null
        ? null
        : fieldDateGroup?.createDateGroupKey(targetDate);

    return targetTrack.getWritesPerDateGroup(fieldDateGroupKey);
  }

  void addReadLog({
    required String fieldCode,
    required DateTime? dateGroupKey,
  }) {
    final sfTrack = _tracks.putIfAbsent(
      fieldCode,
      () => _SFDiagnosticTrack(code: fieldCode),
    );
    sfTrack.addReadLog(dateGroupKey: dateGroupKey);
  }

  void addWriteLog({
    required String fieldCode,
    required DateTime? dateGroupKey,
  }) {
    final sfTrack = _tracks.putIfAbsent(
      fieldCode,
      () => _SFDiagnosticTrack(code: fieldCode),
    );
    sfTrack.addWriteLog(dateGroupKey: dateGroupKey);
  }

  String log({int minInteractionsToLog = 2}) {
    return '${trackedSFslog(minInteractionsToLog: minInteractionsToLog)} \n${summaryLog()}';
  }

  String trackedSFslog({int minInteractionsToLog = 2}) {
    final tracks = _tracks.values
        .where((element) => element.interactions > minInteractionsToLog)
        .sorted(
          (a, b) => a.interactions.compareTo(b.interactions),
        );

    return tracks.map((e) => e.toString()).join('\n');
  }

  String summaryLog() {
    final writes = _tracks.values.map((e) => e.writes).sum;
    final reads = _tracks.values.map((e) => e.reads).sum;

    return 'Summary: writes:$writes | reads: $reads | interactions: $interactions';
  }

  void reset() {
    _tracks.clear();
  }
}

class _SFDiagnosticTrack {
  final String code;
  final Map<DateTime?, int> _readsPerDateGroup = {};
  final Map<DateTime?, int> _writesPerDateGroup = {};

  _SFDiagnosticTrack({
    required this.code,
  });

  int get reads => _readsPerDateGroup.values.sum;

  int get writes => _writesPerDateGroup.values.sum;

  int get interactions => reads + writes;

  int getReadsPerDateGroup(DateTime? dateGroupKey) {
    if (dateGroupKey == null) {
      return reads;
    }

    return _readsPerDateGroup[dateGroupKey] ?? 0;
  }

  int getWritesPerDateGroup(DateTime? dateGroupKey) {
    if (dateGroupKey == null) {
      return writes;
    }

    return _writesPerDateGroup[dateGroupKey] ?? 0;
  }

  void addReadLog({required DateTime? dateGroupKey}) {
    _readsPerDateGroup.update(
      dateGroupKey,
      (value) => value + 1,
      ifAbsent: () => 1,
    );
  }

  void addWriteLog({required DateTime? dateGroupKey}) {
    _writesPerDateGroup.update(
      dateGroupKey,
      (value) => value + 1,
      ifAbsent: () => 1,
    );
  }

  @override
  String toString() {
    final line = ''.padRight(50, '-');

    return [
      'SF:$code',
      'reads: $reads | writes: $writes',
      line,
    ].join('\n');
  }
}
