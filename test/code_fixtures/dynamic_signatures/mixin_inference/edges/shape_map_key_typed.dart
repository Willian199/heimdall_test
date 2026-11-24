import 'support.dart';

class Subject extends HeaderBox<Map<int, int>> with Shape2 {}

Type nativeType() {
  return Subject().inferred;
}
