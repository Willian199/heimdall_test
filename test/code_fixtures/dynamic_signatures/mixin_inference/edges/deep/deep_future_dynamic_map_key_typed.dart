import 'support.dart';

class Subject extends HeaderBox<Future<List<(Map<int, Set<String>>, Map<int, List<bool>>)>>> with Deep3 {}

Type nativeType() {
  return Subject().inferred;
}
