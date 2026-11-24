import 'support.dart';

class Subject extends HeaderBox<Never> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
