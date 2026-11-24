import 'support.dart';

final result = TypedCell(0).optional((TypedCell(1).current, 'fixed'));

Type nativeType() {
  return typeOfValue(result);
}
