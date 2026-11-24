import 'support.dart';

class Subject extends WideBase<int> with Refine {}

final result = Subject().value;

Type nativeType() {
  return typeOfValue(result);
}
