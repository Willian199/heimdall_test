import 'support.dart';

class Subject extends HeaderBox<void Function(void Function(int))> with Shape7 {}

Type nativeType() {
  return Subject().inferred;
}
