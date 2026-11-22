import '../c/model.dart';
import '../b/extensions.dart';

class Consumer {
  String read(dynamic Function() build) => build().description as String;
}
