import 'support.dart';

class Subject extends HeaderBox<dynamic> with TopDefault {}

Type nativeType() {
  return Subject().inferred;
}
