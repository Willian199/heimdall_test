import 'support.dart';

final result = TypedCell(0).second('fixed', DynamicCell(1).current);

Type nativeType() {
  return typeOfValue(result);
}
