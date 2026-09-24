import 'types.dart';

class ForInConsumer {
  void callInIterable() {
    for (final Tools in Tools.actions()) {
      Tools.run();
    }
  }
}
