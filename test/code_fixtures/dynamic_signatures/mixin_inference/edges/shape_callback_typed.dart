import 'support.dart';

class Subject extends HeaderBox<int Function()> with Shape5 {}

Type nativeType() {
  return Subject().inferred;
}
