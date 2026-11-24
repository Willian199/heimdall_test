import 'support.dart';

class Subject extends HeaderBox<Map<String, int>> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
