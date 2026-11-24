import 'support.dart';

class Subject extends HeaderBox<dynamic> with ChainedBounds {}

Type nativeType() {
  return Subject().inferred;
}
