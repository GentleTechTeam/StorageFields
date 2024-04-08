import 'package:storage_fields/src/utils/index.dart';

enum StorageFieldDateGroup {
  exactMoment,
  day,

  /// Calendar week from Monday
  week,

  /// Calendar month from the 1st day
  month,

  /// Spans a 7 day period from T-6 to T inclusive
  sevenDays(daysOffset: 6),

  /// Spans a 21 day period from T-20 to T inclusive
  twentyOneDays(daysOffset: 20),

  /// Spans a 28 day period from T-27 to T inclusive
  twentyEightDays(daysOffset: 27),

  /// Spans a 56 day period from T-55 to T inclusive
  fiftySixDays(daysOffset: 55),

  /// Spans a 90 day period from T-89 to T inclusive
  ninetyDays(daysOffset: 89);

  /// Relevant only for non-calendar periods from `T-daysOffset` to `T` inclusive.
  /// All other cases has 0 value to avoid nullability
  final int daysOffset;

  const StorageFieldDateGroup({this.daysOffset = 0});

  int get weeksOffset => (daysOffset + 1) ~/ 7;

  DateTime createDateGroupKey(DateTime targetDate) {
    switch (this) {
      case StorageFieldDateGroup.exactMoment:
        return targetDate.toUtc();
      case StorageFieldDateGroup.day:
        return targetDate.toStartOfDay();
      case StorageFieldDateGroup.week:
        return targetDate.toStartOfWeek();
      case StorageFieldDateGroup.month:
        return targetDate.toStartOfMonth();
      case StorageFieldDateGroup.sevenDays:
      case StorageFieldDateGroup.twentyOneDays:
      case StorageFieldDateGroup.twentyEightDays:
      case StorageFieldDateGroup.fiftySixDays:
      case StorageFieldDateGroup.ninetyDays:
        return targetDate.toDaysOffsetStart(daysOffset);
    }
  }

  /// Returns date group keys with granularity of [StorageFieldDateGroup.day].
  /// Sorted in ascending order.
  List<DateTime> createDayGranularityDateGroupKeys({
    required DateTime targetDate,
  }) {
    final List<DateTime> result;

    switch (this) {
      case StorageFieldDateGroup.exactMoment:
        result = [];
        break;
      case StorageFieldDateGroup.day:
        result = [targetDate.toStartOfDay()];
        break;
      case StorageFieldDateGroup.week:
        {
          final startOfTargetWeek = targetDate.toStartOfWeek();

          result = List.generate(
            7,
            (index) => startOfTargetWeek.add(Duration(days: index)),
          );

          break;
        }
      case StorageFieldDateGroup.month:
        result = targetDate.daysOfMonth();

        break;
      case StorageFieldDateGroup.sevenDays:
      case StorageFieldDateGroup.twentyOneDays:
      case StorageFieldDateGroup.twentyEightDays:
      case StorageFieldDateGroup.fiftySixDays:
      case StorageFieldDateGroup.ninetyDays:
        result = targetDate.toDaysFromOffset(daysOffset);
        break;
    }

    return result..sort();
  }

  /// Returns date group keys with granularity of [StorageFieldDateGroup.week].
  /// Sorted in ascending order.
  List<DateTime> createWeekGranularityDateGroupKeys({
    required DateTime targetDate,
  }) {
    final List<DateTime> result;

    switch (this) {
      case StorageFieldDateGroup.exactMoment:
        result = [];
        break;
      case StorageFieldDateGroup.day:
        result = [targetDate.toStartOfDay()];
        break;
      case StorageFieldDateGroup.week:
        result = [targetDate.toStartOfWeek()];
        break;
      case StorageFieldDateGroup.month:
        result = targetDate.toCurrentMonthWeekStartList();
        break;
      case StorageFieldDateGroup.sevenDays:
      case StorageFieldDateGroup.twentyOneDays:
      case StorageFieldDateGroup.twentyEightDays:
      case StorageFieldDateGroup.fiftySixDays:
      case StorageFieldDateGroup.ninetyDays:
        result = targetDate.toWeekStartList(weeksOffset);
        break;
    }

    return result..sort();
  }
}
