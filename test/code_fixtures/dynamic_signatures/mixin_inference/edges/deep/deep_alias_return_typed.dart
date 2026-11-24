import 'support.dart';

Payload<int> result() => Future.value((
  'value',
  <int, List<int>>{
    1: [1],
  },
));

Type nativeType() {
  return typeOfValue(result);
}
