import 'support.dart';

class Subject extends Hop<dynamic> with Prior, FromExtra {}

Type nativeType() {
  return Subject().inferred;
}
