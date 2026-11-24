import 'support.dart';

final result = TypedCell(0).optional(ListCell<int>([1]).current);

Type nativeType() {
  return typeOfValue(result);
}
