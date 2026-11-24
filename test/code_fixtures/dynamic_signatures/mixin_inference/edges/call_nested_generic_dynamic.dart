import 'support.dart';

final result = TypedCell(0).identity(TypedCell(0).identity(DynamicCell(1).current));

Type nativeType() {
  return typeOfValue(result);
}
