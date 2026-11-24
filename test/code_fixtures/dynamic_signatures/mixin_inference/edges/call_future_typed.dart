import 'support.dart';

final result = Future.value(TypedCell(1).current);

Type nativeType() {
  return typeOfValue(result);
}
