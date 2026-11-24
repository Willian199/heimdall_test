import 'support.dart';

class Subject extends HeaderBox<(Future<Map<String, List<int>>>, {Stream<Set<int>> changes})> with Deep5 {}

Type nativeType() {
  return Subject().inferred;
}
