import '../models/failure.dart';
import '../extensions/failure_text.dart';

class Consumer {
  final Failure failure = Failure();
  String read() => failure.description;
}
