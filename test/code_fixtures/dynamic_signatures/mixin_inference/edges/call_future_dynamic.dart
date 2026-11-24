import 'support.dart';

final result = Future.value(DynamicCell(1).current);

Type nativeType() {
  return typeOfValue(result);
}
