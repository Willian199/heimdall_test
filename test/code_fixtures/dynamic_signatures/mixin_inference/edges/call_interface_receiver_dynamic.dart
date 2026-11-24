import 'support.dart';

final CellView<dynamic> exposed = DynamicCell(1);
final result = exposed.value;

Type nativeType() {
  return typeOfValue(result);
}
