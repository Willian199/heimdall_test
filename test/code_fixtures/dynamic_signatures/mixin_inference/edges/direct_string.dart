import 'support.dart';

class Subject extends HeaderBox<String> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
