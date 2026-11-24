import 'support.dart';

final result = TypedCell(0).optional(<dynamic>[1]);

Type nativeType() {
  return typeOfValue(result);
}
