import 'support.dart';

class Subject extends Diamond<dynamic> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
