import 'package:storage_fields/storage_fields.dart';

import 'primary_field_wrapper_example.dart';
import 'secondary_field_wrapper_example.dart';

void main() {
  /// We are using stub for example. In real world you will use your own implementation of [StorageFieldsService]
  /// for example Firestore or postgreSQL implementations.
  ///
  final StorageFieldsService storageFieldsService = StorageFieldsServiceStub();
  final userAgeFieldWrapper = UserAgeWrapper(
    storageFieldsService: storageFieldsService,
  );

  final userIsOldFieldWrapper = UserIsOldWrapper(
    storageFieldsService: storageFieldsService,
    userAgeWrapper: userAgeFieldWrapper,
  );
  final now = DateTime.now();

  var userIsOld = userIsOldFieldWrapper.get(date: now);
  print(userIsOld);

  /// Return false because user age is not set

  /// Set user age to 20
  userAgeFieldWrapper.set(value: 20, date: now);

  userIsOld = userIsOldFieldWrapper.get(date: now);
  print(userIsOld);

  /// Return false because user age is less than 30

  /// Set user age to 40
  userAgeFieldWrapper.set(value: 40, date: now);

  userIsOld = userIsOldFieldWrapper.get(date: now);
  print(userIsOld);

  /// Return true because user age is greater than 30
}
