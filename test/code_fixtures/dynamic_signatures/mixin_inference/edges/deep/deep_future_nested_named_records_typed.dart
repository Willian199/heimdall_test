import 'support.dart';

class Subject extends HeaderBox<Future<(String, {Map<int, List<(int, {bool flag})>> payload})>> with Deep7 {}

Type nativeType() {
  return Subject().inferred;
}
