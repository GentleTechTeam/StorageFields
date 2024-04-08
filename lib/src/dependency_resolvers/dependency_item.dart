import 'package:storage_fields/src/models/on_get_field_dates_params.dart';
import 'package:storage_fields/src/wrappers/index.dart';

class DependencyItem<SFValue> {
  final StorageFieldWrapper<SFValue> fieldWrapper;
  final List<DateTime>? Function(
    OnGetFieldDatesParams params,
  ) onGetFieldDates;

  DependencyItem({
    required this.fieldWrapper,
    required this.onGetFieldDates,
  });
}
