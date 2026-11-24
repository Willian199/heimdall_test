import 'support.dart';

final result = [DynamicCell(1).current];

Type nativeType() {
  return typeOfValue(result);
}
