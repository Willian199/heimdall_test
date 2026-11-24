import 'support.dart';

class Subject extends HeaderBox<Future<(String, Map<int, List<int>>)>> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
