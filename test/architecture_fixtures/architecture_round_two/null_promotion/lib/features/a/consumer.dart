import '../c/model.dart';
import '../b/extensions.dart';

class Consumer {
  String read(Failure? value) {
    if (value == null) return '';
    return value.description;
  }
}
