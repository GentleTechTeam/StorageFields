import 'package:storage_fields/src/models/index.dart';

class SecondaryFieldValidityParams implements FieldValidityParams {
  @override
  final ValueValidityType validityType;
  @override
  final StorageFieldDateGroup? dateGroup;

  SecondaryFieldValidityParams._({
    required this.dateGroup,
    required this.validityType,
  });

  factory SecondaryFieldValidityParams.alwaysValid() {
    return SecondaryFieldValidityParams._(
      dateGroup: null,
      validityType: ValueValidityType.alwaysValid,
    );
  }

  factory SecondaryFieldValidityParams.lastIsValid() {
    return SecondaryFieldValidityParams._(
      dateGroup: StorageFieldDateGroup.exactMoment,
      validityType: ValueValidityType.lastIsValid,
    );
  }

  factory SecondaryFieldValidityParams.validForDay() {
    return SecondaryFieldValidityParams._(
      dateGroup: StorageFieldDateGroup.day,
      validityType: ValueValidityType.validForCertainDateGroup,
    );
  }

  factory SecondaryFieldValidityParams.validForWeek() {
    return SecondaryFieldValidityParams._(
      dateGroup: StorageFieldDateGroup.week,
      validityType: ValueValidityType.validForCertainDateGroup,
    );
  }

  factory SecondaryFieldValidityParams.validForMonth() {
    return SecondaryFieldValidityParams._(
      dateGroup: StorageFieldDateGroup.month,
      validityType: ValueValidityType.validForCertainDateGroup,
    );
  }

  factory SecondaryFieldValidityParams.validFor7Days() {
    return SecondaryFieldValidityParams._(
      dateGroup: StorageFieldDateGroup.sevenDays,
      validityType: ValueValidityType.validForCertainDateGroup,
    );
  }

  factory SecondaryFieldValidityParams.validFor21Days() {
    return SecondaryFieldValidityParams._(
      dateGroup: StorageFieldDateGroup.twentyOneDays,
      validityType: ValueValidityType.validForCertainDateGroup,
    );
  }

  factory SecondaryFieldValidityParams.validFor28Days() {
    return SecondaryFieldValidityParams._(
      dateGroup: StorageFieldDateGroup.twentyEightDays,
      validityType: ValueValidityType.validForCertainDateGroup,
    );
  }

  factory SecondaryFieldValidityParams.validFor56Days() {
    return SecondaryFieldValidityParams._(
      dateGroup: StorageFieldDateGroup.fiftySixDays,
      validityType: ValueValidityType.validForCertainDateGroup,
    );
  }

  factory SecondaryFieldValidityParams.validFor90Days() {
    return SecondaryFieldValidityParams._(
      dateGroup: StorageFieldDateGroup.ninetyDays,
      validityType: ValueValidityType.validForCertainDateGroup,
    );
  }
}
