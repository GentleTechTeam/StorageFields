import 'package:storage_fields/src/dependency_resolvers/index.dart';

class DependencyResolveResult2<I1, I2> implements DependencyResolveResult {
  final List<I1?> item1;
  final List<I2?> item2;

  const DependencyResolveResult2({
    required this.item1,
    required this.item2,
  });

  @override
  DependencyResolveResult merge(DependencyResolveResult other) {
    if (other is DependencyResolveResult2<I1, I2>) {
      return DependencyResolveResult2<I1, I2>(
        item1: item1.merge(other.item1),
        item2: item2.merge(other.item2),
      );
    } else {
      throw Exception('Invalid type: ${other.runtimeType}');
    }
  }
}
