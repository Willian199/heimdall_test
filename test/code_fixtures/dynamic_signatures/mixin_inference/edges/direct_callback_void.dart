import 'support.dart';

class Subject extends HeaderBox<void Function()> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
