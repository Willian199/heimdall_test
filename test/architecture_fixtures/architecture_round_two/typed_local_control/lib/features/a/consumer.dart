import '../c/model.dart';
import '../b/extensions.dart';

class Consumer {
  String read() {
    final Failure value = sharedFailure;
    return value.description;
  }
}
