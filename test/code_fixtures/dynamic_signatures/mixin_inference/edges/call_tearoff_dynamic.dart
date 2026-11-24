import 'support.dart';

final result = DynamicCell(1).fetch;

Type nativeType() {
  return typeOfValue(result);
}
