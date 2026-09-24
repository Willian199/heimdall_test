import 'types.dart';

class InstanceConsumer {
  final Action Tools = Action();

  void callInstance(Action Tools) {
    Tools.run();
  }

  void callLocal() {
    final Tools = Action();
    Tools.run();
  }

  void callField() {
    Tools.run();
  }
}
