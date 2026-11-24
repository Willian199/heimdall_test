import 'support.dart';

class Subject with Carrier<int>, HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
