import 'support.dart';

class Subject extends HeaderBox<dynamic> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
