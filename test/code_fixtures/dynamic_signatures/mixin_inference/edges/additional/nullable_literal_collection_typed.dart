import 'support.dart';

final result = TypedCell(0).optional(<int>[1]);

Type nativeType() {
  return typeOfValue(result);
}
