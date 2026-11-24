import 'support.dart';

class Subject extends HeaderBox<List<Object?>> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
