import 'support.dart';

class Subject extends HeaderBox<FutureOr<(String, Map<int, List<int>>)>> with Deep8 {}

Type nativeType() {
  return Subject().inferred;
}
