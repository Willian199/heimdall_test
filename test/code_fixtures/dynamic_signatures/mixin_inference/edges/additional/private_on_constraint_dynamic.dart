import 'support.dart';

class Subject extends PublicPrivate<dynamic> with PrivateAccess {}

Type nativeType() {
  return Subject().inferred;
}
