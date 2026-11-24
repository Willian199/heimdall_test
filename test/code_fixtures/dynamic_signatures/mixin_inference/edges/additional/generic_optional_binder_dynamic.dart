import 'support.dart';

class Subject extends HeaderBox<dynamic Function<X>([X? value])> with OptionalClosure {}

Type nativeType() {
  return Subject().inferred;
}
