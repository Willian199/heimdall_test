import 'support.dart';

class Subject extends HeaderBox<Future<Map<int, List<(String, dynamic Function())>>>> with Deep6 {}

Type nativeType() {
  return Subject().inferred;
}
