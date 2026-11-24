import 'support.dart';

final _source = AsyncCell<dynamic>(
  Future.value((
    'value',
    <int, List<dynamic>>{
      1: [1],
    },
  )),
);
final result = TypedCell(0).optional(_source.current);

Type nativeType() {
  return typeOfValue(result);
}
