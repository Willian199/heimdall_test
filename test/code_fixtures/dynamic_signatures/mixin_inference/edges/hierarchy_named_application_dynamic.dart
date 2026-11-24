import 'support.dart';

class Subject = Hop<dynamic> with HeaderAccess;

Type nativeType() {
  return Subject().inferred;
}
