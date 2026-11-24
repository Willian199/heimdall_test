import 'support.dart';

class Subject extends HeaderBox<dynamic Function()> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
