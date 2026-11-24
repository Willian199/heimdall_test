import 'support.dart';

class Subject extends Composite<dynamic> with Multiple {}

Type nativeType() {
  return Subject().inferred;
}
