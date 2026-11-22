import '../models/failure.dart';
import '../extensions/failure_text.dart';

extension LocalText on Failure {
  String get description => 'local';
}

class Consumer {
  String read(Failure failure) => failure.description;
}
