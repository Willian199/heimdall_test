import '../models/failure.dart';
import '../extensions/failure_text.dart';

Failure createFailure() => Failure();

class Consumer {
  String read() => createFailure().description;
}
