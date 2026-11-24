import 'support.dart';

class Subject extends Implementation<dynamic> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
