import 'support.dart';

final Members<dynamic> exposed = DynamicCell(1);
final result = exposed.fetch();

Type nativeType() {
  return typeOfValue(result);
}
