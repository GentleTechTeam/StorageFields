import 'package:storage_fields/src/dependency_resolvers/index.dart';

class DependencyResolveResult5<I1, I2, I3, I4, I5>
    implements DependencyResolveResult {
  final List<I1?> item1;
  final List<I2?> item2;
  final List<I3?> item3;
  final List<I4?> item4;
  final List<I5?> item5;

  const DependencyResolveResult5({
    required this.item1,
    required this.item2,
    required this.item3,
    required this.item4,
    required this.item5,
  });

  @override
  DependencyResolveResult merge(DependencyResolveResult other) {
    if (other is DependencyResolveResult5<I1, I2, I3, I4, I5>) {
      return DependencyResolveResult5<I1, I2, I3, I4, I5>(
        item1: item1.merge(other.item1),
        item2: item2.merge(other.item2),
        item3: item3.merge(other.item3),
        item4: item4.merge(other.item4),
        item5: item5.merge(other.item5),
      );
    } else {
      throw Exception('Invalid type: ${other.runtimeType}');
    }
  }
}
