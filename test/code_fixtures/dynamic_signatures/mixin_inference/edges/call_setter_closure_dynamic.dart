import 'support.dart';

final result = (int next) {
  DynamicCell(1).current = next;
};

Type nativeType() {
  return typeOfValue(result);
}
