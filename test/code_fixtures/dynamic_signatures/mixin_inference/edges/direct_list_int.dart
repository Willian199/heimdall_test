import 'support.dart';

class Subject extends HeaderBox<List<int>> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
