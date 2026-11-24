import 'support.dart';

final result = TypedCell(0).optional(TypedCell(1).current);

Type nativeType() {
  return typeOfValue(result);
}
