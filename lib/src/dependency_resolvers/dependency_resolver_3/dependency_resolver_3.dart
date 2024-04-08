import 'package:storage_fields/src/dependency_resolvers/index.dart';

class DependencyResolver3<SFValue1, SFValue2, SFValue3>
    extends DependencyResolver<
        DependencyResolveResult3<SFValue1, SFValue2, SFValue3>> {
  final DependencyItem<SFValue1> dep1;
  final DependencyItem<SFValue2> dep2;
  final DependencyItem<SFValue3> dep3;

  DependencyResolver3({
    required this.dep1,
    required this.dep2,
    required this.dep3,
  });

  @override
  List<DependencyItem<Object?>> get dependencies => [dep1, dep2, dep3];

  @override
  DependencyResolveResult3<SFValue1, SFValue2, SFValue3>
      mapDependencyValuesToResult(
    List<List<Object?>> values,
  ) {
    return DependencyResolveResult3(
      item1: values.first.cast<SFValue1?>(),
      item2: values[1].cast<SFValue2?>(),
      item3: values[2].cast<SFValue3?>(),
    );
  }
}
