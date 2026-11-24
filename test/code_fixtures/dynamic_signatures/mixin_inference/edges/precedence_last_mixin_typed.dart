import 'support.dart';

class Subject extends WideBase<int> with Earlier, Refine {}

final result = Subject().read();

Type nativeType() {
  return typeOfValue(result);
}
