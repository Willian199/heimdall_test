import '../c/model.dart';
import '../b/extensions.dart';

Failure build() => Failure();

class Consumer {
  String read(dynamic Function() build) => build().description as String;
}
