import 'package:storage_fields/src/value_formatters/index.dart';
import 'package:test/test.dart';

void main() {
  group('DirectValueFormatter', () {
    test('Returns correct value for String', () {
      const formatter = DirectValueFormatter(value: 'Some string');

      expect(formatter.format(locale: null), 'Some string');
    });
    test('Returns correct value for int', () {
      const formatter = DirectValueFormatter(value: 777);

      expect(formatter.format(locale: null), '777');
    });

    test('Returns correct value for double', () {
      const formatter = DirectValueFormatter(value: 0.5);

      expect(formatter.format(locale: null), '0.5');
    });

    test('Returns correct value for true', () {
      const formatter = DirectValueFormatter(value: true);

      expect(formatter.format(locale: null), 'true');
    });

    test('Returns correct value for false', () {
      const formatter = DirectValueFormatter(value: false);

      expect(formatter.format(locale: null), 'false');
    });
  });
}
