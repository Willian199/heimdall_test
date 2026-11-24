import 'support.dart';

final result = (DynamicCell(1)..replace(2)).current;

Type nativeType() {
  return typeOfValue(result);
}
