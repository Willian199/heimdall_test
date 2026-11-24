import 'support.dart';

class Subject extends HeaderBox<ReorderedAlias<dynamic, String>> with Shape9 {}

Type nativeType() {
  return Subject().inferred;
}
