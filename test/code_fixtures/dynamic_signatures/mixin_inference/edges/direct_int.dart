import 'support.dart';

class Subject extends HeaderBox<int> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
