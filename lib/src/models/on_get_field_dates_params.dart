import 'package:meta/meta.dart';

@internal
class OnGetFieldDatesParams {
  final DateTime date;
  final DateTime? baseDate;

  const OnGetFieldDatesParams({
    required this.date,
    required this.baseDate,
  });
}
