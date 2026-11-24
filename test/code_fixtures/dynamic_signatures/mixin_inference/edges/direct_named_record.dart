import 'support.dart';

class Subject extends HeaderBox<(int, {String value})> with HeaderAccess {}

Type nativeType() {
  return Subject().inferred;
}
