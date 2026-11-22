import '../models/failure.dart';
import '../extensions/failure_text.dart';

class Consumer {
  String read(Other value) => value.description;
}
