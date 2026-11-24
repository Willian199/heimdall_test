import 'support.dart';

class Subject extends HeaderBox<ReorderedAlias<int, String>> with Shape9 {}

Type nativeType() {
  return Subject().inferred;
}
