import 'support.dart';

class Subject extends HeaderBox<int Function<X>([X? value])> with OptionalClosure {}

Type nativeType() {
  return Subject().inferred;
}
