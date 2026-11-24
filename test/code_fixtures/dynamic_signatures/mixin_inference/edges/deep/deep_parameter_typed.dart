import 'support.dart';

void accept(Future<(String, Map<int, List<int>>)> value) {}

Type nativeType() {
  return typeOfValue(accept);
}
