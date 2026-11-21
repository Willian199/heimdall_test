import '../c/model.dart';
import '../b/extensions.dart';

class Consumer {
  String read(dynamic value, dynamic Function() replace) {
    if (value is Failure) {
      value = replace();
      return value.description as String;
    }
    return '';
  }
}
