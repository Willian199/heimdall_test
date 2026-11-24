import 'support.dart';

class Subject extends Diamond<int> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
