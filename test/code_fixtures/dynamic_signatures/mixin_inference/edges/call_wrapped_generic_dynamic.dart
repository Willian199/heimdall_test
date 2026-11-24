import 'support.dart';

final result = TypedCell(0).wrap(DynamicCell(1).current);

Type nativeType() {
  return typeOfValue(result);
}
