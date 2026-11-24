import 'support.dart';

class Subject extends ConcreteHop<dynamic> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
