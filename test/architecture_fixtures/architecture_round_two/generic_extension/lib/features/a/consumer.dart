import '../c/model.dart';
import '../b/extensions.dart';

class Consumer {
  String read(Box<int> value) => value.label;
}
