import 'support.dart';

class Subject extends ShadowHop<dynamic> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
