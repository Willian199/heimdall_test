import 'support.dart';

class Subject extends ConcreteHop<int> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
