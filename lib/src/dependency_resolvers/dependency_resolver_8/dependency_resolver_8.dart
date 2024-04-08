import 'package:storage_fields/src/dependency_resolvers/index.dart';

class DependencyResolver8<SFValue1, SFValue2, SFValue3, SFValue4, SFValue5,
        SFValue6, SFValue7, SFValue8>
    extends DependencyResolver<
        DependencyResolveResult8<SFValue1, SFValue2, SFValue3, SFValue4,
            SFValue5, SFValue6, SFValue7, SFValue8>> {
  final DependencyItem<SFValue1> dep1;
  final DependencyItem<SFValue2> dep2;
  final DependencyItem<SFValue3> dep3;
  final DependencyItem<SFValue4> dep4;
  final DependencyItem<SFValue5> dep5;
  final DependencyItem<SFValue6> dep6;
  final DependencyItem<SFValue7> dep7;
  final DependencyItem<SFValue8> dep8;

  DependencyResolver8({
    required this.dep1,
    required this.dep2,
    required this.dep3,
    required this.dep4,
    required this.dep5,
    required this.dep6,
    required this.dep7,
    required this.dep8,
  });

  @override
  List<DependencyItem<Object?>> get dependencies => [
        dep1,
        dep2,
        dep3,
        dep4,
        dep5,
        dep6,
        dep7,
        dep8,
      ];

  @override
  DependencyResolveResult8<SFValue1, SFValue2, SFValue3, SFValue4, SFValue5,
      SFValue6, SFValue7, SFValue8> mapDependencyValuesToResult(
    List<List<Object?>> values,
  ) {
    return DependencyResolveResult8(
      item1: values.first.cast<SFValue1?>(),
      item2: values[1].cast<SFValue2?>(),
      item3: values[2].cast<SFValue3?>(),
      item4: values[3].cast<SFValue4?>(),
      item5: values[4].cast<SFValue5?>(),
      item6: values[5].cast<SFValue6?>(),
      item7: values[6].cast<SFValue7?>(),
      item8: values[7].cast<SFValue8?>(),
    );
  }
}
