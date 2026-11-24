import 'support.dart';

final result = Future.value(1).then(
  (_) => (
    'value',
    <int, List<dynamic>>{
      1: [1],
    },
  ),
);

Type nativeType() {
  return typeOfValue(result);
}
