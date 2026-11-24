import 'support.dart';

class Subject extends HeaderBox<(Future<Map<String, List<dynamic>>>, {Stream<Set<dynamic>> changes})> with Deep5 {}

Type nativeType() {
  return Subject().inferred;
}
