import 'support.dart';

final result = [TypedCell(1).current];

Type nativeType() {
  return typeOfValue(result);
}
