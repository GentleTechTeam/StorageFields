import 'package:intl/locale.dart';
import 'package:storage_fields/src/value_formatters/index.dart';

class EmptyValueFormatter extends SFValueFormatter<Object?> {
  const EmptyValueFormatter() : super(value: null);

  @override
  String format({
    required Locale? locale,
  }) {
    return '';
  }
}
