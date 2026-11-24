import 'support.dart';

class Subject extends HeaderBox<void Function(void Function(dynamic))> with Shape7 {}

Type nativeType() {
  return Subject().inferred;
}
