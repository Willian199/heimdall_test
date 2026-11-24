import 'support.dart';

class Subject extends WideBase<dynamic> with Earlier, Refine {}

final result = Subject().read();

Type nativeType() {
  return typeOfValue(result);
}
