import 'support.dart';

class Subject extends HeaderBox<int> with Nullable {}

Type nativeType() {
  return Subject().inferred;
}
