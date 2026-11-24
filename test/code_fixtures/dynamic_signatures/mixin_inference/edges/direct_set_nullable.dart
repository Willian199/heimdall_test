import 'support.dart';

class Subject extends HeaderBox<Set<int?>> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
