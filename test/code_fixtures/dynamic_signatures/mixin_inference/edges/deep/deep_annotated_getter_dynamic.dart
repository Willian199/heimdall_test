import 'support.dart';

Future<(String, Map<int, List<dynamic>>)> get result => Future.value((
  'value',
  <int, List<dynamic>>{
    1: [1],
  },
));

Type nativeType() {
  return typeOfValue(result);
}
