import 'support.dart';

final result = TypedCell(0).named(next: DynamicCell(1).current);

Type nativeType() {
  return typeOfValue(result);
}
