import 'package:storage_fields/src/models/index.dart';
import 'package:test/test.dart';

// ignore: long-method
void main() {
  /// Wednesday, the 7th of June 2023
  final tDate = DateTime.utc(2023, 6, 7);

  group('createDayGranularityDateGroupKeys', () {
    test(
      'exact moment',
      () async {
        final weeks = StorageFieldDateGroup.exactMoment
            .createDayGranularityDateGroupKeys(targetDate: tDate);
        expect(weeks, <DateTime>[]);
      },
    );
    test(
      'day',
      () async {
        final weeks = StorageFieldDateGroup.day
            .createDayGranularityDateGroupKeys(targetDate: tDate);
        expect(weeks, <DateTime>[
          DateTime.utc(tDate.year, tDate.month, tDate.day),
        ]);
      },
    );
    test(
      'week',
      () async {
        final weeks =
            StorageFieldDateGroup.week.createDayGranularityDateGroupKeys(
          targetDate: tDate,
        );
        expect(
          weeks,
          _allDaysBetweenRange(
            begin: DateTime.utc(2023, 06, 05),
            end: DateTime.utc(2023, 06, 11),
          ),
        );
      },
    );
    test(
      'seven days',
      () async {
        final weeks =
            StorageFieldDateGroup.sevenDays.createDayGranularityDateGroupKeys(
          targetDate: tDate,
        );
        expect(
          weeks,
          _allDaysBetweenRange(
            begin: DateTime.utc(2023, 06),
            end: DateTime.utc(2023, 06, 07),
          ),
        );
      },
    );
    test(
      'twenty one days',
      () async {
        final weeks = StorageFieldDateGroup.twentyOneDays
            .createDayGranularityDateGroupKeys(
          targetDate: tDate,
        );
        expect(
          weeks,
          _allDaysBetweenRange(
            begin: DateTime.utc(2023, 05, 18),
            end: DateTime.utc(2023, 06, 07),
          ),
        );
      },
    );
    test(
      'twenty eight days',
      () async {
        final weeks = StorageFieldDateGroup.twentyEightDays
            .createDayGranularityDateGroupKeys(
          targetDate: tDate,
        );
        expect(
          weeks,
          _allDaysBetweenRange(
            begin: DateTime.utc(2023, 05, 11),
            end: DateTime.utc(2023, 06, 07),
          ),
        );
      },
    );
    test(
      'fifty six days',
      () async {
        final weeks = StorageFieldDateGroup.fiftySixDays
            .createDayGranularityDateGroupKeys(
          targetDate: tDate,
        );
        expect(
          weeks,
          _allDaysBetweenRange(
            begin: DateTime.utc(2023, 04, 13),
            end: DateTime.utc(2023, 06, 07),
          ),
        );
      },
    );
    test(
      'ninety days',
      () async {
        final weeks =
            StorageFieldDateGroup.ninetyDays.createDayGranularityDateGroupKeys(
          targetDate: tDate,
        );
        expect(
          weeks,
          _allDaysBetweenRange(
            begin: DateTime.utc(2023, 03, 10),
            end: DateTime.utc(2023, 06, 07),
          ),
        );
      },
    );
  });

  group(
    'createWeekGranularityDateGroupKeys',
    () {
      test(
        'exact moment',
        () async {
          final weeks = StorageFieldDateGroup.exactMoment
              .createWeekGranularityDateGroupKeys(targetDate: tDate);
          expect(weeks, <DateTime>[]);
        },
      );
      test(
        'day',
        () async {
          final weeks = StorageFieldDateGroup.day
              .createWeekGranularityDateGroupKeys(targetDate: tDate);
          expect(weeks, [
            DateTime.utc(tDate.year, tDate.month, tDate.day),
          ]);
        },
      );
      test(
        'week',
        () async {
          final weeks =
              StorageFieldDateGroup.week.createWeekGranularityDateGroupKeys(
            targetDate: DateTime.utc(2023, 5, 6),
          );
          expect(weeks, [DateTime.utc(2023, 5)]);
        },
      );
      test(
        'seven days',
        () async {
          final weeks = StorageFieldDateGroup.sevenDays
              .createWeekGranularityDateGroupKeys(
            targetDate: DateTime.utc(2023, 5, 5),
          );
          expect(weeks, [
            DateTime.utc(2023, 5),
          ]);
        },
      );
      test(
        'twenty one days',
        () async {
          final weeks = StorageFieldDateGroup.twentyOneDays
              .createWeekGranularityDateGroupKeys(
            targetDate: DateTime.utc(2023, 5, 5),
          );
          expect(weeks, [
            DateTime.utc(2023, 4, 17),
            DateTime.utc(2023, 4, 24),
            DateTime.utc(2023, 5),
          ]);
        },
      );
      test(
        'twenty eight days',
        () async {
          final weeks = StorageFieldDateGroup.twentyEightDays
              .createWeekGranularityDateGroupKeys(
            targetDate: DateTime.utc(2023, 5, 5),
          );
          expect(weeks, [
            DateTime.utc(2023, 4, 10),
            DateTime.utc(2023, 4, 17),
            DateTime.utc(2023, 4, 24),
            DateTime.utc(2023, 5),
          ]);
        },
      );
      test(
        'fifty six days',
        () async {
          final weeks = StorageFieldDateGroup.fiftySixDays
              .createWeekGranularityDateGroupKeys(
            targetDate: DateTime.utc(2023, 5, 5),
          );
          expect(weeks, [
            DateTime.utc(2023, 03, 13),
            DateTime.utc(2023, 3, 20),
            DateTime.utc(2023, 3, 27),
            DateTime.utc(2023, 4, 03),
            DateTime.utc(2023, 4, 10),
            DateTime.utc(2023, 4, 17),
            DateTime.utc(2023, 4, 24),
            DateTime.utc(2023, 5),
          ]);
        },
      );
      test(
        'ninety days',
        () async {
          final weeks = StorageFieldDateGroup.ninetyDays
              .createWeekGranularityDateGroupKeys(
            targetDate: DateTime.utc(2023, 5, 5),
          );
          expect(weeks, [
            DateTime.utc(2023, 2, 13),
            DateTime.utc(2023, 2, 20),
            DateTime.utc(2023, 2, 27),
            DateTime.utc(2023, 3, 6),
            DateTime.utc(2023, 3, 13),
            DateTime.utc(2023, 3, 20),
            DateTime.utc(2023, 3, 27),
            DateTime.utc(2023, 4, 3),
            DateTime.utc(2023, 4, 10),
            DateTime.utc(2023, 4, 17),
            DateTime.utc(2023, 4, 24),
            DateTime.utc(2023, 5),
          ]);
        },
      );
      test(
        'month with no start weeks',
        () async {
          final weeks =
              StorageFieldDateGroup.month.createWeekGranularityDateGroupKeys(
            targetDate: DateTime.utc(2023, 6, 4),
          );
          expect(weeks, <DateTime>[]);
        },
      );
      test(
        'month with one week',
        () async {
          final weeks =
              StorageFieldDateGroup.month.createWeekGranularityDateGroupKeys(
            targetDate: DateTime.utc(2023, 6, 6),
          );
          expect(weeks, [
            DateTime.utc(2023, 6, 5),
          ]);
        },
      );
      test(
        'month with two weeks',
        () async {
          final weeks =
              StorageFieldDateGroup.month.createWeekGranularityDateGroupKeys(
            targetDate: DateTime.utc(2023, 6, 13),
          );
          expect(weeks, [
            DateTime.utc(2023, 6, 5),
            DateTime.utc(2023, 6, 12),
          ]);
        },
      );
      test(
        'month with three weeks',
        () async {
          final weeks =
              StorageFieldDateGroup.month.createWeekGranularityDateGroupKeys(
            targetDate: DateTime.utc(2023, 6, 21),
          );
          expect(weeks, [
            DateTime.utc(2023, 6, 5),
            DateTime.utc(2023, 6, 12),
            DateTime.utc(2023, 6, 19),
          ]);
        },
      );
      test(
        'month with two weeks',
        () async {
          final weeks =
              StorageFieldDateGroup.month.createWeekGranularityDateGroupKeys(
            targetDate: DateTime.utc(2023, 5, 12),
          );
          expect(weeks, [
            DateTime.utc(2023, 5),
            DateTime.utc(2023, 5, 8),
          ]);
        },
      );
      test(
        'month with four weeks',
        () async {
          final weeks =
              StorageFieldDateGroup.month.createWeekGranularityDateGroupKeys(
            targetDate: DateTime.utc(2023, 6, 26),
          );
          expect(weeks, [
            DateTime.utc(2023, 6, 5),
            DateTime.utc(2023, 6, 12),
            DateTime.utc(2023, 6, 19),
            DateTime.utc(2023, 6, 26),
          ]);
        },
      );
    },
  );
}

List<DateTime> _allDaysBetweenRange({
  required DateTime begin,
  required DateTime end,
}) {
  final numberOfDays = end.difference(begin);

  return List.generate(
    numberOfDays.inDays + 1,
    (index) => begin.add(Duration(days: index)),
  );
}
