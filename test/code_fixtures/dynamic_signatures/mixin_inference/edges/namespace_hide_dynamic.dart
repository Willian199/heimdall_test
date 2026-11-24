import 'barrel.dart' hide HeaderBox, Hop;

class Subject extends Hop2<dynamic> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
