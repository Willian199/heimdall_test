import 'support.dart';

class Subject extends HeaderBox<int> with Bounded {}

Type nativeType() {
  return Subject().inferred;
}
