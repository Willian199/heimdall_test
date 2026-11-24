import 'support.dart';

class Subject extends ShadowHop<int> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
