import 'support.dart';

enum Subject with Carrier<int>, HeaderAccess { value }

Type nativeType() {
  return Subject.value.inferred;
}
