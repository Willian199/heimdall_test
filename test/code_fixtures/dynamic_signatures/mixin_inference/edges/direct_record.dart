import 'support.dart';

class Subject extends HeaderBox<(int, String)> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
