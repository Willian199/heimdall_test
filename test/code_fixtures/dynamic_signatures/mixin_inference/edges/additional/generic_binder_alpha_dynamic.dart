import 'support.dart';

class Subject extends HeaderBox<dynamic Function<X>(X)> with GenericClosure {}

Type nativeType() {
  return Subject().inferred;
}
