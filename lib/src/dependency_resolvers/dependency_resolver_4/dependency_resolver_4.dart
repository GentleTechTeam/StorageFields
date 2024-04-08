import 'package:storage_fields/src/dependency_resolvers/index.dart';

class DependencyResolver4<SFValue1, SFValue2, SFValue3, SFValue4>
    extends DependencyResolver<
        DependencyResolveResult4<SFValue1, SFValue2, SFValue3, SFValue4>> {
  final DependencyItem<SFValue1> dep1;
  final DependencyItem<SFValue2> dep2;
  final DependencyItem<SFValue3> dep3;
  final DependencyItem<SFValue4> dep4;

  DependencyResolver4({
    required this.dep1,
    required this.dep2,
    required this.dep3,
    required this.dep4,
  });

  @override
  List<DependencyItem<Object?>> get dependencies => [
        dep1,
        dep2,
        dep3,
        dep4,
      ];

  @override
  DependencyResolveResult4<SFValue1, SFValue2, SFValue3, SFValue4>
      mapDependencyValuesToResult(
    List<List<Object?>> values,
  ) {
    return DependencyResolveResult4(
      item1: values.first.cast<SFValue1?>(),
      item2: values[1].cast<SFValue2?>(),
      item3: values[2].cast<SFValue3?>(),
      item4: values[3].cast<SFValue4?>(),
    );
  }
}
