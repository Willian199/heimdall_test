import 'support.dart';

class Subject extends HeaderBox<Repeated<int, int>> with RepeatedAccess {}

Type nativeType() {
  return Subject().inferred;
}
