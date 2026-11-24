import 'support.dart';

final result = TypedCell(1).fetch();

Type nativeType() {
  return typeOfValue(result);
}
