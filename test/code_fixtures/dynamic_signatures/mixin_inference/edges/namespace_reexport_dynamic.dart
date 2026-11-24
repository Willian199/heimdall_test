import 'reexport.dart';

class Subject extends Hop2<dynamic> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
