import 'support.dart';

class Subject extends HeaderBox<Future<(String, {Map<int, List<int>> payload})>> with Deep1 {}

Type nativeType() {
  return Subject().inferred;
}
