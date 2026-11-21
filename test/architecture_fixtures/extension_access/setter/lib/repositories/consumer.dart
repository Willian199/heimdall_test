import '../models/failure.dart';
import '../extensions/failure_text.dart';

class Consumer {
  void write(Failure failure) {
    failure.description = 'new';
  }
}
