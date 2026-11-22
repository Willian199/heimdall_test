import '../c/model.dart';
import '../b/extensions.dart';

class Consumer {
  String read(Object value) {
    if (value is! Failure) return '';
    return value.description;
  }
}
