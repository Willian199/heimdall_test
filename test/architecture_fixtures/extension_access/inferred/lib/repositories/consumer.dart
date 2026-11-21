import '../models/failure.dart';
import '../extensions/failure_text.dart';

class Consumer {
  String read() {
    final failure = Failure();
    return failure.description;
  }
}
