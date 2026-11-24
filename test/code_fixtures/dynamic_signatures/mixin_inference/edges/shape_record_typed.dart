import 'support.dart';

class Subject extends HeaderBox<(int, int)> with Shape3 {}

Type nativeType() {
  return Subject().inferred;
}
