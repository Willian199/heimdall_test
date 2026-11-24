import 'support.dart';

final result = TypedCell(0).optional(Future<int>.value(1));

Type nativeType() {
  return typeOfValue(result);
}
