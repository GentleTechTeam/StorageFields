import 'package:storage_fields/src/value_formatters/index.dart';
import 'package:test/test.dart';

void main() {
  group('SFValueForFormatter', () {
    group('factory', () {
      test('returns EmptyValueFormatter formatter for null value', () {
        const Duration? value = null;
        final formatter = SFValueFormatter.fromValue(value);

        expect(formatter, isA<EmptyValueFormatter>());
      });

      test(
        'returns UndetailedDurationValueFormatter formatter for Duration',
        () {
          final formatter = SFValueFormatter.fromValue(const Duration(days: 1));

          expect(formatter, isA<UndetailedDurationValueFormatter>());
        },
      );

      test('returns DirectValueFormatter formatter for String', () {
        final formatter = SFValueFormatter.fromValue('Some string');

        expect(formatter, isA<DirectValueFormatter>());
      });

      test('returns DirectValueFormatter formatter for int', () {
        final formatter = SFValueFormatter.fromValue(777);

        expect(formatter, isA<DirectValueFormatter>());
      });
      test('returns DirectValueFormatter formatter for double', () {
        final formatter = SFValueFormatter.fromValue(0.5);

        expect(formatter, isA<DirectValueFormatter>());
      });

      test('returns DirectValueFormatter formatter for number', () {
        const num value = 777;
        final formatter = SFValueFormatter.fromValue(value);

        expect(formatter, isA<DirectValueFormatter>());
      });

      test('returns DirectValueFormatter formatter for bool', () {
        final formatter = SFValueFormatter.fromValue(true);

        expect(formatter, isA<DirectValueFormatter>());
      });

      test('returns DirectValueFormatter formatter for List', () {
        final formatter = SFValueFormatter.fromValue([1, 2]);

        expect(formatter, isA<DirectValueFormatter>());
      });

      test('returns DirectValueFormatter formatter for Map', () {
        final formatter = SFValueFormatter.fromValue({'foo': 'bar'});

        expect(formatter, isA<DirectValueFormatter>());
      });

      test('returns DirectValueFormatter formatter for Set', () {
        final formatter = SFValueFormatter.fromValue({'foo', 'bar'});

        expect(formatter, isA<DirectValueFormatter>());
      });
    });
  });
}
