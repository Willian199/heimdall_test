import 'support.dart';

class Subject extends HeaderBox<Future<dynamic>> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
