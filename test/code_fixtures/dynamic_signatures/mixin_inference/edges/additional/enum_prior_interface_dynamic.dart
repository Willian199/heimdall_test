import 'support.dart';

enum Subject with Carrier<dynamic>, HeaderAccess { value }

Type nativeType() {
  return Subject.value.inferred;
}
