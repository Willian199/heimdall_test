import '../models/failure.dart';
import '../extensions/failure_text.dart';

class Consumer {
  String read(dynamic failure) => failure.description as String;
}
