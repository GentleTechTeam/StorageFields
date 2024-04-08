import 'package:storage_fields/src/dependency_resolvers/index.dart';

class DependencyResolveResult1<I1> implements DependencyResolveResult {
  final List<I1?> item1;

  const DependencyResolveResult1({required this.item1});

  @override
  DependencyResolveResult merge(DependencyResolveResult other) {
    if (other is DependencyResolveResult1<I1>) {
      return DependencyResolveResult1<I1>(
        item1: item1.merge(other.item1),
      );
    } else {
      throw Exception('Invalid type: ${other.runtimeType}');
    }
  }
}
