import '../c/model.dart';
import '../b/extensions.dart';

class Consumer {
  String read<T extends Failure>(T value) => value.description;
}
