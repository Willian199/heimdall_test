import 'support.dart';

class Subject extends HeaderBox<dynamic> with Unbounded {}

Type nativeType() {
  return Subject().inferred;
}
