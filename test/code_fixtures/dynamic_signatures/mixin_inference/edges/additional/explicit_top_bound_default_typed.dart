import 'support.dart';

class Subject extends HeaderBox<int> with TopDefault {}

Type nativeType() {
  return Subject().inferred;
}
