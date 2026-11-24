import 'reexport.dart';

class Subject extends Hop2<int> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
