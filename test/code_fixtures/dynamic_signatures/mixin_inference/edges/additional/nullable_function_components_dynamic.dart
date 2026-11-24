import 'support.dart';

final result = TypedCell(0).optional(() => DynamicCell(1).current);

Type nativeType() {
  return typeOfValue(result);
}
