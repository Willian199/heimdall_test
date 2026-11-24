import 'support.dart';

class Subject extends HeaderBox<dynamic> with Nullable {}

Type nativeType() {
  return Subject().inferred;
}
