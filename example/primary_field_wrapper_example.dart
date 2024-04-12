import 'package:json_annotation/src/json_converter.dart';
import 'package:storage_fields/storage_fields.dart';

//ignore: prefer-match-file-name
class UserAgeWrapper extends PrimaryStorageFieldWrapper<int> {
  @override
  final StorageFieldsService storageFieldsService;

  UserAgeWrapper({
    required this.storageFieldsService,
  });

  @override
  String get fieldCode => 'user_age';

  @override

  /// This means that the last value that was written to this field will be valid.
  /// For example, we recorded on February 10 that the age is 40 years old.
  /// And on February 20, the user had a birthday and we overwritten this field and the value became 41.
  /// For example, if we request the value of this field on February 22, the value 41 will be returned.
  /// But if we send the date to the request before February 20, then 40 years will be returned.
  PrimaryFieldValidityParams get validityParams =>
      PrimaryFieldValidityParams.lastIsValid();

  @override

  /// Converts value to JSON and vice versa
  JsonConverter<int?, Object?> get valueConverter => const IntValueConverter();
}

class IntValueConverter implements JsonConverter<int?, Object?> {
  const IntValueConverter();

  @override
  int? fromJson(Object? json) {
    if (json is! num) {
      return null;
    }

    return json.toInt();
  }

  @override
  int? toJson(int? value) {
    return value;
  }
}
