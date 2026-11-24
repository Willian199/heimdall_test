import 'support.dart';

class Subject extends HeaderBox<Map<dynamic, int>> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
