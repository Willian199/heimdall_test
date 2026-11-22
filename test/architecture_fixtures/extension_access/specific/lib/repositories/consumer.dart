import '../models/failure.dart';
import '../extensions/failure_text.dart';
import '../allowed_extensions/narrow.dart';

class Consumer {
  String read(Failure failure) => failure.description;
}
