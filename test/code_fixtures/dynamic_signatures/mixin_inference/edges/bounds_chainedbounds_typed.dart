import 'support.dart';

class Subject extends HeaderBox<int> with ChainedBounds {}

Type nativeType() {
  return Subject().inferred;
}
