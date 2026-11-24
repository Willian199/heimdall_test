import 'support.dart';

final result = TypedCell(0).optional(Stream.value(DynamicCell(1).current));

Type nativeType() {
  return typeOfValue(result);
}
