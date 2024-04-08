import 'package:meta/meta.dart';

// ignore: one_member_abstracts
abstract class DependencyResolveResult {
  DependencyResolveResult merge(DependencyResolveResult other);
}

extension DepsResultListExtension<T> on List<T?> {
  @internal
  List<T?> merge(List<T?> other) {
    final result = <T?>[];

    //TODO: Use elementAtOrNull when upgrading to collection 1.17.x+
    for (var index = 0; index < length; index++) {
      final otherListElement =
          other.length >= length ? other.elementAt(index) : null;
      result.add(otherListElement ?? elementAt(index));
    }

    return result;
  }
}
