import 'support.dart';

Type _received = Object;
set result(Future<(String, Map<int, List<dynamic>>)> value) {
  _received = typeOfValue(value);
}

Type nativeType() {
  result = Future.value((
    'value',
    <int, List<dynamic>>{
      1: [1],
    },
  ));
  return _received;
}
