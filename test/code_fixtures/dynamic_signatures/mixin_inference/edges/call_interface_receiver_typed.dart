import 'support.dart';

final CellView<int> exposed = TypedCell(1);
final result = exposed.value;

Type nativeType() {
  return typeOfValue(result);
}
