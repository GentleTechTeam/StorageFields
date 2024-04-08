import 'package:intl/locale.dart';
import 'package:storage_fields/src/value_formatters/index.dart';

class UndetailedDurationValueFormatter extends SFValueFormatter<Duration> {
  const UndetailedDurationValueFormatter({required super.value});

  @override
  String format({
    required Locale? locale,
  }) {
    final moreThanDay = value.inHours > 23;
    if (moreThanDay) {
      return '${(value.inHours ~/ 24).toInt().toString()} days';
    }

    final remainderMinutes = value.inMinutes % 60;

    return '${value.inHours}h ${remainderMinutes.toString().padLeft(2, '0')}m';
  }
}
