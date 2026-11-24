import 'support.dart';

Type _lastType = Object;

class Subject extends WideBase<int> with Refine {
  @override
  set value(next) {
    _lastType = typeOfValue(next);
  }
}

Type nativeType() {
  Subject().value = 1;
  return _lastType;
}
