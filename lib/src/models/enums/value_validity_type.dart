enum ValueValidityType {
  alwaysValid,
  lastIsValid,
  validForCertainDateGroup;

  bool get dateGroupKeyRequired {
    switch (this) {
      case ValueValidityType.validForCertainDateGroup:
        return true;
      case ValueValidityType.alwaysValid:
      case ValueValidityType.lastIsValid:
        return false;
    }
  }

  DateTime? get defaultDate {
    switch (this) {
      case ValueValidityType.validForCertainDateGroup:
      case ValueValidityType.alwaysValid:
        return null;
      case ValueValidityType.lastIsValid:
        return DateTime.now().toUtc();
    }
  }
}
