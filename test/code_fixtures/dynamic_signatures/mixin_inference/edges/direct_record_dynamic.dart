import 'support.dart';

class Subject extends HeaderBox<(int, dynamic)> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
