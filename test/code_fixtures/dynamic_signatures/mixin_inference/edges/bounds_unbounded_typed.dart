import 'support.dart';

class Subject extends HeaderBox<int> with Unbounded {}

Type nativeType() {
  return Subject().inferred;
}
