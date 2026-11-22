import '../models/failure.dart';
import '../extensions/barrel.dart';

class Consumer {
  String read(Failure failure) => failure.description;
}
