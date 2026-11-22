import '../models/failure.dart';
import '../extensions/failure_text.dart';

class Consumer {
  Consumer(this.failure) : text = failure.description;
  final Failure failure;
  final String text;
}
