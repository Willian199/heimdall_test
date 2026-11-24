import 'support.dart';

Future<(String, Map<int, List<int>>)> get result => Future.value((
  'value',
  <int, List<int>>{
    1: [1],
  },
));

Type nativeType() {
  return typeOfValue(result);
}
