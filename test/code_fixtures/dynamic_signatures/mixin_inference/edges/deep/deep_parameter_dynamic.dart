import 'support.dart';

void accept(Future<(String, Map<int, List<dynamic>>)> value) {}

Type nativeType() {
  return typeOfValue(accept);
}
