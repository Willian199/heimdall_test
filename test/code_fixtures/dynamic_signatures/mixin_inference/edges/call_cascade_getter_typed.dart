import 'support.dart';

final result = (TypedCell(1)..replace(2)).current;

Type nativeType() {
  return typeOfValue(result);
}
