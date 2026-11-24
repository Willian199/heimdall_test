import 'support.dart';

class Subject extends HeaderBox<Stream<int>> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
