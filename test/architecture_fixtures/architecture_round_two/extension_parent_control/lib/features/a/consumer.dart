import '../c/model.dart';
import '../b/extensions.dart';

class Consumer {
  String read(Derived<int> value) => value.label;
}
