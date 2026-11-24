import 'support.dart';

class Subject extends HeaderBox<Object> with HeaderAccess<Object> {}

Type nativeType() {
  return Subject().inferred;
}
