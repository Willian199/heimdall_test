import 'support.dart';

class Subject extends HeaderBox<Repeated<dynamic, dynamic>> with RepeatedAccess {}

Type nativeType() {
  return Subject().inferred;
}
