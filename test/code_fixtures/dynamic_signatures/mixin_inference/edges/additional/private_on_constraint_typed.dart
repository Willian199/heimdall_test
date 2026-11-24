import 'support.dart';

class Subject extends PublicPrivate<int> with PrivateAccess {}

Type nativeType() {
  return Subject().inferred;
}
