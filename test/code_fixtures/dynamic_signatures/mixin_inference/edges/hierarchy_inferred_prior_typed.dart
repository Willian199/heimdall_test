import 'support.dart';

class Subject extends Hop<int> with Prior, FromExtra {}

Type nativeType() {
  return Subject().inferred;
}
