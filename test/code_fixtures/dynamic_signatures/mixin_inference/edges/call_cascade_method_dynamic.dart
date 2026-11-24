import 'support.dart';

final result = (DynamicCell(1)..current = 2).fetch();

Type nativeType() {
  return typeOfValue(result);
}
