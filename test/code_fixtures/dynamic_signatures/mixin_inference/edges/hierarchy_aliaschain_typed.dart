import 'support.dart';

class Subject extends AliasChain<int> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
