import 'package:storage_fields/src/dependency_resolvers/index.dart';

class DependencyResolveResult6<I1, I2, I3, I4, I5, I6>
    implements DependencyResolveResult {
  final List<I1?> item1;
  final List<I2?> item2;
  final List<I3?> item3;
  final List<I4?> item4;
  final List<I5?> item5;
  final List<I6?> item6;

  const DependencyResolveResult6({
    required this.item1,
    required this.item2,
    required this.item3,
    required this.item4,
    required this.item5,
    required this.item6,
  });

  @override
  DependencyResolveResult merge(DependencyResolveResult other) {
    if (other is DependencyResolveResult6<I1, I2, I3, I4, I5, I6>) {
      return DependencyResolveResult6<I1, I2, I3, I4, I5, I6>(
        item1: item1.merge(other.item1),
        item2: item2.merge(other.item2),
        item3: item3.merge(other.item3),
        item4: item4.merge(other.item4),
        item5: item5.merge(other.item5),
        item6: item6.merge(other.item6),
      );
    } else {
      throw Exception('Invalid type: ${other.runtimeType}');
    }
  }
}
