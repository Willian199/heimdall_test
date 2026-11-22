import '../models/failure.dart';
import '../extensions/failure_text.dart';

class Consumer {
  Failure get failure => Failure();
  String read() => failure.description;
}
