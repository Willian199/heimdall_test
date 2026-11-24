import 'support.dart';

class Subject extends WideBase<dynamic> with Refine {
  @override
  get value => 1;
}

final result = Subject().value;

Type nativeType() {
  return typeOfValue(result);
}
