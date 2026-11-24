import 'support.dart';

class Subject extends HeaderBox<Future<(String, Map<int, List<dynamic>>)>> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
