import 'support.dart';

final result = {'value': DynamicCell(1).current};

Type nativeType() {
  return typeOfValue(result);
}
