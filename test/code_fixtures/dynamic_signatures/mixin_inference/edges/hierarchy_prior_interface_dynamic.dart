import 'support.dart';

class Subject with Carrier<dynamic>, HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
