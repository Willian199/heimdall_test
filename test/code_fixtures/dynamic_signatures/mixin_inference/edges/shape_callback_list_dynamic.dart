import 'support.dart';

class Subject extends HeaderBox<List<dynamic> Function()> with Shape6 {}

Type nativeType() {
  return Subject().inferred;
}
