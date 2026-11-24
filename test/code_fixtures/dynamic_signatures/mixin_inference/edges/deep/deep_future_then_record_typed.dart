import 'support.dart';

final result = Future.value(1).then(
  (_) => (
    'value',
    <int, List<int>>{
      1: [1],
    },
  ),
);

Type nativeType() {
  return typeOfValue(result);
}
