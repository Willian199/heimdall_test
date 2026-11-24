import 'support.dart';

class Subject extends HeaderBox<Repeated<int, int>> with DroppedAccess {}

Type nativeType() {
  return Subject().inferred;
}
