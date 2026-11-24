import 'support.dart';

final Members<int> exposed = TypedCell(1);
final result = exposed.fetch();

Type nativeType() {
  return typeOfValue(result);
}
