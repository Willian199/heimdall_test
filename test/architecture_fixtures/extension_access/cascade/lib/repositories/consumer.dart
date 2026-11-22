import '../models/failure.dart';
import '../extensions/failure_text.dart';

class Consumer {
  void read(Failure failure) {
    failure..describe();
  }
}
