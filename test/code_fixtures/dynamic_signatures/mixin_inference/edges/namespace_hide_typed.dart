import 'barrel.dart' hide HeaderBox, Hop;

class Subject extends Hop2<int> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
