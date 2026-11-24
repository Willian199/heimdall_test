import 'support.dart';

class Subject extends HeaderBox<(int, {dynamic value})> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
