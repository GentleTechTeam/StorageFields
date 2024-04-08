import 'package:storage_fields/src/dependency_resolvers/index.dart';

class DependencyResolver2<SFValue1, SFValue2>
    extends DependencyResolver<DependencyResolveResult2<SFValue1, SFValue2>> {
  final DependencyItem<SFValue1> dep1;
  final DependencyItem<SFValue2> dep2;

  DependencyResolver2({
    required this.dep1,
    required this.dep2,
  });

  @override
  List<DependencyItem<Object?>> get dependencies => [dep1, dep2];

  @override
  DependencyResolveResult2<SFValue1, SFValue2> mapDependencyValuesToResult(
    List<List<Object?>> values,
  ) {
    return DependencyResolveResult2(
      item1: values.first.cast<SFValue1?>(),
      item2: values[1].cast<SFValue2?>(),
    );
  }
}
