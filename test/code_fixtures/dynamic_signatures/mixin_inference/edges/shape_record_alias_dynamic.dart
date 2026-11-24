import 'support.dart';

class Subject extends HeaderBox<RecordAlias<dynamic>> with Shape8 {}

Type nativeType() {
  return Subject().inferred;
}
