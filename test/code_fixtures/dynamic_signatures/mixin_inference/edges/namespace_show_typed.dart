import 'barrel.dart' show Hop2, HeaderAccess;

class Subject extends Hop2<int> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
