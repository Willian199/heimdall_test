import 'support.dart';

final result = () async => await Future.value((
  'value',
  <int, List<dynamic>>{
    1: [1],
  },
));

Type nativeType() {
  return typeOfValue(result);
}
