import 'support.dart';

Future<(String, Map<int, List<int>>)> result() => Future.value((
  'value',
  <int, List<int>>{
    1: [1],
  },
));

Type nativeType() {
  return typeOfValue(result);
}
