import 'support.dart';

class Subject extends AliasChain<dynamic> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
