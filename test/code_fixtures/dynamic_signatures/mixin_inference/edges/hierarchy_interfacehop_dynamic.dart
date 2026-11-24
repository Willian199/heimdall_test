import 'support.dart';

class Subject extends InterfaceImplementation<dynamic> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
