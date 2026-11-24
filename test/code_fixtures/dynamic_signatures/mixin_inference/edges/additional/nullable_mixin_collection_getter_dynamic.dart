import 'support.dart';

final result = TypedCell(0).optional(ListCell<dynamic>([1]).current);

Type nativeType() {
  return typeOfValue(result);
}
