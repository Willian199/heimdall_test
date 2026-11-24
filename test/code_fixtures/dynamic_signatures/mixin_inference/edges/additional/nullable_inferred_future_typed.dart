import 'support.dart';

final result = TypedCell(0).optional(Future.value(TypedCell(1).current));

Type nativeType() {
  return typeOfValue(result);
}
