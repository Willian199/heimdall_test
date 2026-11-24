import 'support.dart';

class Subject extends InterfaceImplementation<int> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
