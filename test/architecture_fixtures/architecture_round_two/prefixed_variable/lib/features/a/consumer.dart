import '../c/model.dart' as model;
import '../b/extensions.dart';

class Consumer {
  String read() => model.sharedFailure.description;
}
