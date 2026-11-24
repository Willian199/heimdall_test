import 'support.dart';

class Subject extends Hop<int> with HeaderAccess, FromAccess {}

Type nativeType() {
  return Subject().recovered;
}
