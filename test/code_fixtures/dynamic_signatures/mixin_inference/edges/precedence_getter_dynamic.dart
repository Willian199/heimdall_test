import 'support.dart';

class Subject extends WideBase<dynamic> with Refine {}

final result = Subject().value;

Type nativeType() {
  return typeOfValue(result);
}
