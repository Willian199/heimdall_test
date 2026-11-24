import 'support.dart';

final result = Stream.value(DynamicCell(1).current);

Type nativeType() {
  return typeOfValue(result);
}
