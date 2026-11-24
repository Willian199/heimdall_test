import 'support.dart';

class Subject extends WideBase<int> with GetterOnly, MethodOnly {}

final result = Subject().value;

Type nativeType() {
  return typeOfValue(result);
}
