import 'support.dart';

class Subject extends HeaderBox<(int, {dynamic value})> with Shape4 {}

Type nativeType() {
  return Subject().inferred;
}
