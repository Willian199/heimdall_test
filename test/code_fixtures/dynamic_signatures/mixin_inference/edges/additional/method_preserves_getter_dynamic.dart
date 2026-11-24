import 'support.dart';

class Subject extends WideBase<dynamic> with GetterOnly, MethodOnly {}

final result = Subject().value;

Type nativeType() {
  return typeOfValue(result);
}
