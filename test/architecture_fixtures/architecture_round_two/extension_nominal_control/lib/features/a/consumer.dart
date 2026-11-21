import '../c/model.dart';
import '../b/extensions.dart';

extension FallbackText on Object {
  String get label => 'fallback';
}

class Consumer {
  String read(Other<int> value) => value.label;
}
