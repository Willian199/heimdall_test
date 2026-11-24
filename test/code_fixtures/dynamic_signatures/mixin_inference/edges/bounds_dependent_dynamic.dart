import 'support.dart';

class Subject extends HeaderBox<dynamic> with Dependent {}

Type nativeType() {
  return Subject().inferred;
}
