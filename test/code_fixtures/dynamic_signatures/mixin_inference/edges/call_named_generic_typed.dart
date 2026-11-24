import 'support.dart';

final result = TypedCell(0).named(next: TypedCell(1).current);

Type nativeType() {
  return typeOfValue(result);
}
