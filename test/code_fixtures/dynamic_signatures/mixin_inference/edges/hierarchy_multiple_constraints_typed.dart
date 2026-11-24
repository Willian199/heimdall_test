import 'support.dart';

class Subject extends Composite<int> with Multiple {}

Type nativeType() {
  return Subject().inferred;
}
