import 'support.dart';

class Subject extends HeaderBox<Stream<(int, Future<Map<String, List<int>>>)>> with Deep2 {}

Type nativeType() {
  return Subject().inferred;
}
