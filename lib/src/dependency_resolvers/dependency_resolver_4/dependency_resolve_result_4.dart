import 'package:storage_fields/src/dependency_resolvers/index.dart';

class DependencyResolveResult4<I1, I2, I3, I4>
    implements DependencyResolveResult {
  final List<I1?> item1;
  final List<I2?> item2;
  final List<I3?> item3;
  final List<I4?> item4;

  const DependencyResolveResult4({
    required this.item1,
    required this.item2,
    required this.item3,
    required this.item4,
  });

  @override
  DependencyResolveResult merge(DependencyResolveResult other) {
    if (other is DependencyResolveResult4<I1, I2, I3, I4>) {
      return DependencyResolveResult4<I1, I2, I3, I4>(
        item1: item1.merge(other.item1),
        item2: item2.merge(other.item2),
        item3: item3.merge(other.item3),
        item4: item4.merge(other.item4),
      );
    } else {
      throw Exception('Invalid type: ${other.runtimeType}');
    }
  }
}
