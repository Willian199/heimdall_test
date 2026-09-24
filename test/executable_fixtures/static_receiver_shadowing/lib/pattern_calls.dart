import 'types.dart';

class PatternConsumer {
  void callElse(Object value) {
    if (value case Action Tools) {
      Tools.run();
    } else {
      Tools.run();
    }
  }
}
