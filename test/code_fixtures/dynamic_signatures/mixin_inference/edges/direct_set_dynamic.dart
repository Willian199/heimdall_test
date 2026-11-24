import 'support.dart';

class Subject extends HeaderBox<Set<dynamic>> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
