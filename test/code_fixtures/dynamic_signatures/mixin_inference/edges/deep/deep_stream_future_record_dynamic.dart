import 'support.dart';

class Subject extends HeaderBox<Stream<(int, Future<Map<String, List<dynamic>>>)>> with Deep2 {}

Type nativeType() {
  return Subject().inferred;
}
