import 'support.dart';

class Subject extends HeaderBox<Future<List<(Map<dynamic, Set<String>>, Map<int, List<bool>>)>>> with Deep3 {}

Type nativeType() {
  return Subject().inferred;
}
