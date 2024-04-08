import 'package:storage_fields/src/models/index.dart';

class PrimaryFieldValidityParams implements FieldValidityParams {
  @override
  final ValueValidityType validityType;
  @override
  final StorageFieldDateGroup? dateGroup;

  PrimaryFieldValidityParams._({
    required this.validityType,
    required this.dateGroup,
  });

  factory PrimaryFieldValidityParams.alwaysValid() {
    return PrimaryFieldValidityParams._(
      validityType: ValueValidityType.alwaysValid,
      dateGroup: null,
    );
  }

  factory PrimaryFieldValidityParams.lastIsValid() {
    return PrimaryFieldValidityParams._(
      validityType: ValueValidityType.lastIsValid,
      dateGroup: StorageFieldDateGroup.exactMoment,
    );
  }

  factory PrimaryFieldValidityParams.validForDay() {
    return PrimaryFieldValidityParams._(
      validityType: ValueValidityType.validForCertainDateGroup,
      dateGroup: StorageFieldDateGroup.day,
    );
  }

  factory PrimaryFieldValidityParams.validForWeek() {
    return PrimaryFieldValidityParams._(
      validityType: ValueValidityType.validForCertainDateGroup,
      dateGroup: StorageFieldDateGroup.week,
    );
  }

  factory PrimaryFieldValidityParams.validForMonth() {
    return PrimaryFieldValidityParams._(
      validityType: ValueValidityType.validForCertainDateGroup,
      dateGroup: StorageFieldDateGroup.month,
    );
  }
}
