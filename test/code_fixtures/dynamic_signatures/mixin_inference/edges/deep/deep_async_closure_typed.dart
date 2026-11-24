import 'support.dart';

final result = () async => await Future.value((
  'value',
  <int, List<int>>{
    1: [1],
  },
));

Type nativeType() {
  return typeOfValue(result);
}
