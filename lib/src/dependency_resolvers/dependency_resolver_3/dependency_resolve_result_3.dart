import 'package:storage_fields/src/dependency_resolvers/index.dart';

class DependencyResolveResult3<I1, I2, I3> implements DependencyResolveResult {
  final List<I1?> item1;
  final List<I2?> item2;
  final List<I3?> item3;

  const DependencyResolveResult3({
    required this.item1,
    required this.item2,
    required this.item3,
  });

  @override
  DependencyResolveResult merge(DependencyResolveResult other) {
    if (other is DependencyResolveResult3<I1, I2, I3>) {
      return DependencyResolveResult3<I1, I2, I3>(
        item1: item1.merge(other.item1),
        item2: item2.merge(other.item2),
        item3: item3.merge(other.item3),
      );
    } else {
      throw Exception('Invalid type: ${other.runtimeType}');
    }
  }
}
