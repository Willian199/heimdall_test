import 'support.dart';

final result = (int next) {
  TypedCell(1).current = next;
};

Type nativeType() {
  return typeOfValue(result);
}
