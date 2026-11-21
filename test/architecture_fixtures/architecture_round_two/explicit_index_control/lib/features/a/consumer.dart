import '../c/model.dart';
import '../b/extensions.dart';

class Consumer {
  int read(Failure value) => FailureOps(value)[0];
}
