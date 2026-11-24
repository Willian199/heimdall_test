import 'support.dart';

class Subject extends HeaderBox<int Function<X>(X)> with GenericClosure {}

Type nativeType() {
  return Subject().inferred;
}
