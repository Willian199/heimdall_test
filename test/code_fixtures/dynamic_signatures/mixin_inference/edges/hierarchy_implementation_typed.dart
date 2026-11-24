import 'support.dart';

class Subject extends Implementation<int> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
