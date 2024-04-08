import 'package:storage_fields/src/dependency_resolvers/index.dart';

class DependencyResolver6<SFValue1, SFValue2, SFValue3, SFValue4, SFValue5,
        SFValue6>
    extends DependencyResolver<
        DependencyResolveResult6<SFValue1, SFValue2, SFValue3, SFValue4,
            SFValue5, SFValue6>> {
  final DependencyItem<SFValue1> dep1;
  final DependencyItem<SFValue2> dep2;
  final DependencyItem<SFValue3> dep3;
  final DependencyItem<SFValue4> dep4;
  final DependencyItem<SFValue5> dep5;
  final DependencyItem<SFValue6> dep6;

  DependencyResolver6({
    required this.dep1,
    required this.dep2,
    required this.dep3,
    required this.dep4,
    required this.dep5,
    required this.dep6,
  });

  @override
  List<DependencyItem<Object?>> get dependencies => [
        dep1,
        dep2,
        dep3,
        dep4,
        dep5,
        dep6,
      ];

  @override
  DependencyResolveResult6<SFValue1, SFValue2, SFValue3, SFValue4, SFValue5,
      SFValue6> mapDependencyValuesToResult(
    List<List<Object?>> values,
  ) {
    return DependencyResolveResult6(
      item1: values.first.cast<SFValue1?>(),
      item2: values[1].cast<SFValue2?>(),
      item3: values[2].cast<SFValue3?>(),
      item4: values[3].cast<SFValue4?>(),
      item5: values[4].cast<SFValue5?>(),
      item6: values[5].cast<SFValue6?>(),
    );
  }
}
