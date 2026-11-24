import 'support.dart';

class Subject extends HeaderBox<dynamic Function()> with Shape5 {}

Type nativeType() {
  return Subject().inferred;
}
