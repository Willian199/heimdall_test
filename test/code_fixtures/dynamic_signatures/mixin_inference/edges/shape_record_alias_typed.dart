import 'support.dart';

class Subject extends HeaderBox<RecordAlias<int>> with Shape8 {}

Type nativeType() {
  return Subject().inferred;
}
