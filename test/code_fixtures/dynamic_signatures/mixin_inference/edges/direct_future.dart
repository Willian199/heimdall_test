import 'support.dart';

class Subject extends HeaderBox<Future<int>> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
