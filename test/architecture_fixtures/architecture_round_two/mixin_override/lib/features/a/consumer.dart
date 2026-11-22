import '../c/model.dart';
import '../b/extensions.dart';

class Consumer extends Parent with Specific {
  String read() => item.description;
}
