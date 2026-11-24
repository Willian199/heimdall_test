import 'support.dart';

class Subject extends WideBase<int> with Refine, Empty {}

final result = Subject().read();

Type nativeType() {
  return typeOfValue(result);
}
