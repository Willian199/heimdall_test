import 'support.dart';

final result = {'value': TypedCell(1).current};

Type nativeType() {
  return typeOfValue(result);
}
