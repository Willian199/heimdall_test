import 'support.dart';

final result = TypedCell(1).current = 2;

Type nativeType() {
  return typeOfValue(result);
}
