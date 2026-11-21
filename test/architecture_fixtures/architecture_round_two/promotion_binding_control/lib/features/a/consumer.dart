import '../c/model.dart';
import '../b/extensions.dart';

class Consumer {
  String read(Object value) {
    if (value is Failure) {
      {
        final value = Other();
        return value.description;
      }
    }
    return '';
  }
}
