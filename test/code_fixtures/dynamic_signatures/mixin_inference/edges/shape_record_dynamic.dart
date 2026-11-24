import 'support.dart';

class Subject extends HeaderBox<(dynamic, int)> with Shape3 {}

Type nativeType() {
  return Subject().inferred;
}
