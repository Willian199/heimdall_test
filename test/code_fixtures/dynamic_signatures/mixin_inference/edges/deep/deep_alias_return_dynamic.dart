import 'support.dart';

Payload<dynamic> result() => Future.value((
  'value',
  <int, List<dynamic>>{
    1: [1],
  },
));

Type nativeType() {
  return typeOfValue(result);
}
