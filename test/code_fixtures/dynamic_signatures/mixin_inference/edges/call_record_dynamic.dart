import 'support.dart';

final result = (DynamicCell(1).current, 'fixed');

Type nativeType() {
  return typeOfValue(result);
}
