# StorageFields
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

The StorageFields provides a convenient solution for storing and utilizing data. With the ability to implement the `StorageFieldsService` using various databases such as Firestore or Postgres, this library offers flexibility and adaptability to different data storage needs.

## Features:

- **Primary Storage Fields:** Designed for simple data storage, Primary Storage Fields handle basic information such as age, gender, and usernames. They are ideal for data that requires straightforward storage and retrieval without dependencies or calculations.

- **Secondary Storage Fields:** Offering a more advanced solution, Secondary Storage Fields allow for complex data handling. These fields can utilize other wrappers as dependencies and perform calculations based on their values. For example, users can calculate whether a user is considered "old" based on their age and name.

## Benefits:

- **Convenience:** The StorageFields simplifies data management for managers and analysts, providing an easy-to-use format for handling data storage and retrieval.

- **Flexibility:** Users can leverage the library's features to tailor data storage and manipulation according to their specific requirements, enhancing adaptability across different projects and scenarios.

## Installation

To add our package to your dependencies, you can include it in your `pubspec.yaml` and call `dart pub get`.

## Usage:

Implement your own StorageFieldService, define primary and secondary wrappers and you are ready to go.

```dart
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
```

## License

This project is licensed under the [MIT License](LICENSE).

## Contact

- Author: Gentle Tech Team
- Email: gentletechteam@gmail.com
- Website: [gentletech.net](gentletech.net)


