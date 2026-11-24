import 'support.dart';

final result = TypedCell(0).optional((DynamicCell(1).current, 'fixed'));

Type nativeType() {
  return typeOfValue(result);
}
