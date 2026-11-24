import 'support.dart';

class Subject extends HeaderBox<List<dynamic>> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
