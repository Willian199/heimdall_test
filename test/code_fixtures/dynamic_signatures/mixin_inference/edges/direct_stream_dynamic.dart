import 'support.dart';

class Subject extends HeaderBox<Stream<dynamic>> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
