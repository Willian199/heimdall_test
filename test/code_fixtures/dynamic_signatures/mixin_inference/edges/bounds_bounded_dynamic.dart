import 'support.dart';

class Subject extends HeaderBox<dynamic> with Bounded {}

Type nativeType() {
  return Subject().inferred;
}
