import 'support.dart';

final result = DynamicCell(1).current = 2;

Type nativeType() {
  return typeOfValue(result);
}
