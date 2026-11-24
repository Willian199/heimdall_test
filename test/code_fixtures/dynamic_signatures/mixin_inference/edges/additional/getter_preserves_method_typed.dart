import 'support.dart';

class Subject extends WideBase<int> with MethodOnly, GetterOnly {}

final result = Subject().read();

Type nativeType() {
  return typeOfValue(result);
}
