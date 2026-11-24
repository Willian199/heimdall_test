import 'support.dart';

class Subject extends HeaderBox<void> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
