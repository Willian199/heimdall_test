import 'support.dart' as p;

class Subject extends p.Hop2<dynamic> with p.HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
