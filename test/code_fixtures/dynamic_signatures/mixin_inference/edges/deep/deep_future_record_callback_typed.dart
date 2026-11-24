import 'support.dart';

class Subject extends HeaderBox<Future<Map<int, List<(String, int Function())>>>> with Deep6 {}

Type nativeType() {
  return Subject().inferred;
}
