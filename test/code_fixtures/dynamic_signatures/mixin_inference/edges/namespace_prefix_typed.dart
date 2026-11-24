import 'support.dart' as p;

class Subject extends p.Hop2<int> with p.HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
