import 'support.dart';

final result = TypedCell(0).identity<int>(1);

Type nativeType() {
  return typeOfValue(result);
}
