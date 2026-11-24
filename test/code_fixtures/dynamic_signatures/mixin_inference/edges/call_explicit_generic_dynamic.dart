import 'support.dart';

final result = TypedCell(0).identity<dynamic>(1);

Type nativeType() {
  return typeOfValue(result);
}
