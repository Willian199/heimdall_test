import 'support.dart';

Type _lastType = Object;

class Subject extends Narrow implements AcceptContract<dynamic> {
  @override
  void accept(next) {
    _lastType = typeOfValue(next);
  }
}

Type nativeType() {
  Subject().accept(1);
  return _lastType;
}
