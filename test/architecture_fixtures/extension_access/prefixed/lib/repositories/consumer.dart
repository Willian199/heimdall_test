import '../models/failure.dart';
import '../extensions/failure_text.dart' as text;

class Consumer {
  String read(Failure failure) => failure.description;
}
