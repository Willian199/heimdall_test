import 'support.dart';

class Subject extends HeaderBox<(int, {int value})> with Shape4 {}

Type nativeType() {
  return Subject().inferred;
}
