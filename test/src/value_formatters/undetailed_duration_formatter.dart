import 'package:storage_fields/src/value_formatters/index.dart';
import 'package:test/test.dart';

void main() {
  group('UndetailedDurationValueFormatter', () {
    test('Returns correct value for long duration', () {
      const formatter = UndetailedDurationValueFormatter(
        value: Duration(days: 1, hours: 2, minutes: 3),
      );

      expect(formatter.format(locale: null), '1 days');
    });

    test('Returns correct value for short duration', () {
      const formatter = UndetailedDurationValueFormatter(
        value: Duration(
          hours: 1,
          minutes: 5,
          seconds: 23,
          milliseconds: 123,
        ),
      );

      expect(formatter.format(locale: null), '1h 05m');
    });
  });
}
