import 'support.dart';

class Subject extends HeaderBox<Map<String, int>> with Shape1 {}

Type nativeType() {
  return Subject().inferred;
}
