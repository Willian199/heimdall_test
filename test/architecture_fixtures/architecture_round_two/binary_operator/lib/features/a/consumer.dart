import '../c/model.dart';
import '../b/extensions.dart';

class Consumer {
  Failure combine(Failure left, Failure right) => left + right;
}
