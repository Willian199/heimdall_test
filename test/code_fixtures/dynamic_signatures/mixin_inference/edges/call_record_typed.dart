import 'support.dart';

final result = (TypedCell(1).current, 'fixed');

Type nativeType() {
  return typeOfValue(result);
}
