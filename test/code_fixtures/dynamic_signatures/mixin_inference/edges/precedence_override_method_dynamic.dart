import 'support.dart';

class Subject extends WideBase<dynamic> with Refine {
  @override
  read() => 1;
}

final result = Subject().read();

Type nativeType() {
  return typeOfValue(result);
}
