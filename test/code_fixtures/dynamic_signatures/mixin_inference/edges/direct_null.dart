import 'support.dart';

class Subject extends HeaderBox<Null> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
