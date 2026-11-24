import 'support.dart';

class Subject extends HeaderBox<List<int> Function()> with Shape6 {}

Type nativeType() {
  return Subject().inferred;
}
