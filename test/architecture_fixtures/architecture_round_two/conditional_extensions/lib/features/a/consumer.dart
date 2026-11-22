import '../c/model.dart';
import '../b/extensions.dart' if (dart.library.io) '../c/io_extensions.dart';

class Consumer {
  String read(Failure value) => value.description;
}
