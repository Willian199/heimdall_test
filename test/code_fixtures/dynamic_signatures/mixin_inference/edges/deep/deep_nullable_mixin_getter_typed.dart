import 'support.dart';

final _source = AsyncCell<int>(
  Future.value((
    'value',
    <int, List<int>>{
      1: [1],
    },
  )),
);
final result = TypedCell(0).optional(_source.current);

Type nativeType() {
  return typeOfValue(result);
}
