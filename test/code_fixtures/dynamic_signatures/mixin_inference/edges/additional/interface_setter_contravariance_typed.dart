import 'support.dart';

Type _lastType = Object;

class Subject extends Narrow implements WriteContract<int> {
  @override
  set output(next) {
    _lastType = typeOfValue(next);
  }
}

Type nativeType() {
  Subject().output = 1;
  return _lastType;
}
