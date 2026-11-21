import '../c/model.dart';
import '../b/extensions.dart';

class Consumer {
  num read(int value) => value.clamp(0, 1);
}
