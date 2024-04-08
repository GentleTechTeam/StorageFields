import 'package:intl/intl.dart';

abstract class DateHelper {
  /// Returns a list of date strings containing all dates bewteen [startDate] and [endDate] inclusive.
  /// Date strings will be formatted using supplied [pattern].
  /// Time component of supplied dates will be ignored.
  ///
  /// Typically used for external API calls that require a date parameter in [yyyy-mm-dd] format.
  ///
  static List<String> generateDateStringSequence({
    required DateTime startDate,
    required DateTime endDate,
    required String pattern,
  }) {
    final start = startDate.midnight;
    final end = endDate.midnight;

    final delta = end
        .difference(
          start,
        )
        .inDays
        .abs();

    final formatter = DateFormat(
      pattern,
    );

    final earliest = end.isBefore(start) ? end : start;

    return List<String>.generate(delta + 1, (index) {
      return formatter.format(
        earliest.add(
          Duration(
            days: index,
          ),
        ),
      );
    });
  }

  /// Ensures date string matches supplied regexp.
  ///
  static bool validateDate({
    required String date,
    required String regexp,
  }) {
    if (RegExp(regexp).hasMatch(date)) {
      return true;
    }
    print("Error - date: '$date' is not in expected format: '$regexp'");

    return false;
  }

  /// Ensures date string matches supplied regexp.
  ///
  /// Returns a DateTime for a successful match.
  /// Returns a null on failure.
  ///
  static DateTime? parseDate({
    required String date,
    required String regexp,
  }) {
    try {
      if (!RegExp(regexp).hasMatch(date)) {
        throw Exception('Bad date');
      }

      return DateTime.parse(date);
    } catch (exception) {
      print("Error - date: '$date' is not in expected format: '$regexp'");

      return null;
    }
  }

  /// Ensures date string matches supplied regexp and force to UTC.
  ///
  /// Returns a DateTime for a successful match.
  /// Returns a null on failure.
  ///
  static DateTime parseUTCDate({
    required String date,
    required String regexp,
  }) {
    if (!RegExp(regexp).hasMatch(date)) {
      print("Error - date: '$date' is not in expected format: '$regexp'");
      throw Exception('Bad date');
    }

    return DateTime.parse('${date}T00Z');
  }
}

extension DateTimeExtension on DateTime {
  DateTime get midnight => DateTime.utc(year, month, day);

  bool get containsTimeInfo {
    return hour != 0 ||
        minute != 0 ||
        second != 0 ||
        millisecond != 0 ||
        microsecond != 0;
  }

  int get daysInMonth {
    return toEndOfMonth().difference(toStartOfMonth()).inDays + 1;
  }

  DateTime max(DateTime? other) {
    if (other == null) {
      return this;
    }

    return isAfter(other) ? this : other;
  }

  bool isSameDay(DateTime other) {
    return DateTime.utc(year, month, day).isAtSameMomentAs(
      DateTime.utc(other.year, other.month, other.day),
    );
  }

  bool isSameOrAfter(DateTime other) {
    return isAtSameMomentAs(other) || isAfter(other);
  }

  bool isSameOrBefore(DateTime other) {
    return isAtSameMomentAs(other) || isBefore(other);
  }

  bool isYesterday([DateTime? now]) {
    final nowDate = now ?? DateTime.now().toUtc();
    final yesterday = nowDate.subtract(const Duration(days: 1));

    return isSameDay(yesterday);
  }

  DateTime toStartOfDay() {
    return DateTime.utc(year, month, day);
  }

  DateTime toEndOfDay() {
    return toStartOfDay()
        .add(const Duration(days: 1))
        .subtract(const Duration(microseconds: 1));
  }

  DateTime toStartOfWeek() {
    return toStartOfDay().subtract(
      Duration(days: weekday - 1),
    );
  }

  List<DateTime> toWeekStartList(int numberOfWeeks) {
    return List.generate(
      numberOfWeeks,
      (weekIndex) => toStartOfWeek().subtract(Duration(days: weekIndex * 7)),
    );
  }

  DateTime toStartOfMonth() {
    return DateTime.utc(year, month);
  }

  DateTime toEndOfMonth() {
    if (month == 12) {
      return DateTime.utc(year + 1, 1, 0);
    }

    return DateTime.utc(year, month + 1, 0);
  }

  DateTime toDaysOffsetStart(int daysOffset) {
    return DateTime.utc(year, month, day - daysOffset);
  }

  List<DateTime> daysOfMonth() {
    final startOfMonth = toStartOfMonth();

    return List.generate(
      daysInMonth,
      (index) {
        return startOfMonth.add(Duration(days: index));
      },
    );
  }

  /// The lenght of the result list is `offset + 1` to include the current date
  List<DateTime> toDaysFromOffset(int offset) {
    final offsetStart = toStartOfDay().subtract(Duration(days: offset));

    return List.generate(
      offset + 1,
      (index) => offsetStart.add(Duration(days: index)),
    );
  }

  List<DateTime> toCurrentMonthWeekStartList() {
    return toWeekStartList(day ~/ 7 + 1)
        .where((date) => date.year == year && date.month == month)
        .toList();
  }
}
