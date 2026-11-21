import '../c/model.dart';
import '../b/extensions.dart';

extension FallbackText on Object {
  String get label => 'fallback';
}

class Consumer {
  String read(Box<String> value) => value.label;
}
