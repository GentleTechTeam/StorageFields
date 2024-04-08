/* 
A library for convenient storage and utilization of data. 
You need to write your own implementation for the StorageFieldsService, 
which will utilize any database (Firestore, Postgres, etc.).

After that, you can create Primary and Secondary storage fields wrappers.

Primary - for simple data that does not require dependencies and calculations. 
Data that you simply save and retrieve. (For example, age, gender, username, etc.).

Secondary - for more complex data. The Secondary wrapper can use other wrappers 
as dependencies and based on their values perform calculations and return results. 
For example, you can retrieve the values user_age and user_name from Primary wrappers and based on them,
determine if the user is old or not.

This library is convenient because managers and analysts find it easy to work with 
such a format, and in the technical specifications (TS), they can use the field codes of 
the wrappers to describe logic. For example: If the user has specified that their user_age > 30, 
then certain articles with IDs [30,40,50] should be shown to them.

*/

library storage_fields;

// Resolvers
export 'src/dependency_resolvers/index.dart' show DependencyResolveResult1;
export 'src/dependency_resolvers/index.dart' show DependencyResolveResult2;
export 'src/dependency_resolvers/index.dart' show DependencyResolveResult3;
export 'src/dependency_resolvers/index.dart' show DependencyResolveResult4;
export 'src/dependency_resolvers/index.dart' show DependencyResolveResult5;
export 'src/dependency_resolvers/index.dart' show DependencyResolveResult6;
export 'src/dependency_resolvers/index.dart' show DependencyResolveResult7;
export 'src/dependency_resolvers/index.dart' show DependencyResolveResult8;
export 'src/dependency_resolvers/index.dart' show DependencyResolver;
export 'src/dependency_resolvers/index.dart' show DependencyResolver1;
export 'src/dependency_resolvers/index.dart' show DependencyResolver2;
export 'src/dependency_resolvers/index.dart' show DependencyResolver3;
export 'src/dependency_resolvers/index.dart' show DependencyResolver4;
export 'src/dependency_resolvers/index.dart' show DependencyResolver5;
export 'src/dependency_resolvers/index.dart' show DependencyResolver6;
export 'src/dependency_resolvers/index.dart' show DependencyResolver7;
export 'src/dependency_resolvers/index.dart' show DependencyResolver8;
export 'src/dependency_resolvers/index.dart' show DependencyItem;
//Firestore implementation
export 'src/firestore_implementation/index.dart'
    show BatchFirebaseStorageFieldsService;
export 'src/firestore_implementation/index.dart'
    show FirebaseStorageFieldsService;
// Models
export 'src/models/index.dart';
// Services
export 'src/services/index.dart' show StorageFieldsService;
export 'src/services/index.dart' show BatchingCachingStorageFieldsService;
export 'src/services/index.dart' show StorageFieldsServiceStub;
export 'src/services/index.dart' show StorageFieldsPathUtils;
export 'src/services/index.dart' show BatchStorageFieldsService;
// Wrappers
export 'src/wrappers/index.dart' show StorageFieldWrapper;
export 'src/wrappers/index.dart' show SecondaryStorageFieldWrapper;
export 'src/wrappers/index.dart' show PrimaryStorageFieldWrapper;
export 'src/wrappers/index.dart' show ForwardingStorageFieldWrapper;
