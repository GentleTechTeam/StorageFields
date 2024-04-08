import 'package:storage_fields/src/dependency_resolvers/index.dart';

class DependencyResolver1<SFValue1>
    extends DependencyResolver<DependencyResolveResult1<SFValue1>> {
  final DependencyItem<SFValue1> dep1;

  DependencyResolver1({
    required this.dep1,
  });

  @override
  List<DependencyItem<Object?>> get dependencies => [dep1];

  @override
  DependencyResolveResult1<SFValue1> mapDependencyValuesToResult(
    List<List<Object?>> values,
  ) {
    return DependencyResolveResult1(item1: values.first.cast<SFValue1?>());
  }
}
