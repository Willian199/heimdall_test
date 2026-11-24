import 'support.dart';

class Subject extends HeaderBox<int> with PhantomAccess {}

Type nativeType() {
  return Subject().inferred;
}
