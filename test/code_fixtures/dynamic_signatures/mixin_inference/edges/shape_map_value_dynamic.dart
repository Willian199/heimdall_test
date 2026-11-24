import 'support.dart';

class Subject extends HeaderBox<Map<String, dynamic>> with Shape1 {}

Type nativeType() {
  return Subject().inferred;
}
