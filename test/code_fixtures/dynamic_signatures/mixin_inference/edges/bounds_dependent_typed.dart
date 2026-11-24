import 'support.dart';

class Subject extends HeaderBox<int> with Dependent {}

Type nativeType() {
  return Subject().inferred;
}
