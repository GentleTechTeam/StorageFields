import 'package:storage_fields/src/models/index.dart';

abstract class FieldValidityParams {
  ValueValidityType get validityType;
  StorageFieldDateGroup? get dateGroup;
}
