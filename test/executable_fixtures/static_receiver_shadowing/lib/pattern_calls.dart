import 'types.dart';

class PatternConsumer {
  void callElse(Object value) {
    if (value case final Action Tools) {
      Tools.run();
    } else {
      Tools.run();
    }
  }
}
