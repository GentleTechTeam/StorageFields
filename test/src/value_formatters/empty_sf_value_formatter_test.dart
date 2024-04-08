import 'package:storage_fields/src/value_formatters/index.dart';
import 'package:test/test.dart';

void main() {
  group('EmptyValueFormatter', () {
    test('Returns correct value', () {
      const formatter = EmptyValueFormatter();

      expect(formatter.format(locale: null), '');
    });
  });
}
