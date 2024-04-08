import 'package:intl/locale.dart';
import 'package:meta/meta.dart';
import 'package:storage_fields/src/value_formatters/index.dart';

abstract class SFValueFormatter<SFValue> {
  @protected
  final SFValue value;

  const SFValueFormatter({required this.value});

  static SFValueFormatter<Object?> fromValue<SFValue>(SFValue value) {
    if (value == null) {
      return const EmptyValueFormatter();
    }

    if (value is Duration) {
      return UndetailedDurationValueFormatter(value: value);
    }

    return DirectValueFormatter(value: value);
  }

  String format({
    required Locale? locale,
  });
}
