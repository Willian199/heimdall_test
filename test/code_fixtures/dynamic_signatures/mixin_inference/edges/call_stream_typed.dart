import 'support.dart';

final result = Stream.value(TypedCell(1).current);

Type nativeType() {
  return typeOfValue(result);
}
