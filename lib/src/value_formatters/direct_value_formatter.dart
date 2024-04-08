import 'package:intl/locale.dart';
import 'package:storage_fields/src/value_formatters/index.dart';

class DirectValueFormatter extends SFValueFormatter<Object?> {
  const DirectValueFormatter({required super.value});

  @override
  String format({
    required Locale? locale,
  }) {
    return value.toString();
  }
}
