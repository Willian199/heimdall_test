import 'support.dart';

class Subject extends HeaderBox<Map<String, Future<(Set<int>, List<Map<bool, int>>)>>> with Deep4 {}

Type nativeType() {
  return Subject().inferred;
}
