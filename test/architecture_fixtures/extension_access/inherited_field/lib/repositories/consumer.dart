import '../models/failure.dart';
import '../extensions/failure_text.dart';

class Parent {
  final Failure failure = Failure();
}

class Consumer extends Parent {
  String read() => failure.description;
}
