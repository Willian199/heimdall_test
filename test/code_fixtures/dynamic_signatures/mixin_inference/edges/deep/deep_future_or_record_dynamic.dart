import 'support.dart';

class Subject extends HeaderBox<FutureOr<(String, Map<int, List<dynamic>>)>> with Deep8 {}

Type nativeType() {
  return Subject().inferred;
}
