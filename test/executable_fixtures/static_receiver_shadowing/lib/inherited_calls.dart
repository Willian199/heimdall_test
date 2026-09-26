import 'types.dart';

class BaseConsumer {
  final Action Tools = Action();
}

class InheritedConsumer extends BaseConsumer {
  void callInherited() {
    Tools.run();
  }
}
