import 'package:recase/recase.dart';

/// TODO: Add IN case;
enum FieldValueMatcherType {
  operatorUnspecified,
  lessThan,
  lessThanOrEqual,
  greaterThan,
  greaterThanOrEqual,
  equal,
  notEqual,
  isNotNan,
  arrayContains,
  arrayContainsAny,
  isNotIn(firestoreOpOverride: 'NOT_IN');

  final String? firestoreOpOverride;

  const FieldValueMatcherType({this.firestoreOpOverride});
}

extension FieldValueMatcherTypeExt on FieldValueMatcherType {
  String toFirestoreOp() => firestoreOpOverride ?? name.constantCase;
}
