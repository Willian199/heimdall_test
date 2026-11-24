import 'support.dart';

class Subject extends HeaderBox<Object?> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
