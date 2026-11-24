import 'support.dart';

class Subject extends Hop<dynamic> with HeaderAccess, FromAccess {}

Type nativeType() {
  return Subject().recovered;
}
