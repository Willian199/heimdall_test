import 'support.dart';

class Subject = Hop<int> with HeaderAccess;

Type nativeType() {
  return Subject().inferred;
}
