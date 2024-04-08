import 'package:storage_fields/src/models/index.dart';

class ForwardingFieldValidityParams implements FieldValidityParams {
  @override
  final ValueValidityType validityType;
  @override
  final StorageFieldDateGroup? dateGroup;

  ForwardingFieldValidityParams._({
    required this.validityType,
    required this.dateGroup,
  });

  factory ForwardingFieldValidityParams.validForDay() {
    return ForwardingFieldValidityParams._(
      validityType: ValueValidityType.validForCertainDateGroup,
      dateGroup: StorageFieldDateGroup.day,
    );
  }

  factory ForwardingFieldValidityParams.lastIsValid() {
    return ForwardingFieldValidityParams._(
      validityType: ValueValidityType.lastIsValid,
      dateGroup: StorageFieldDateGroup.exactMoment,
    );
  }
}
