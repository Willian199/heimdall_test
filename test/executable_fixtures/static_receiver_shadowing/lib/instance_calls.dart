import 'types.dart';

class InstanceConsumer {
  final Action Tools = Action();

  void callInstance(Action Tools) {
    Tools.run();
  }

  void callLocal() {
    final Tools = Action();
    // This separate call is the syntax covered by the regression test.
    // ignore: cascade_invocations
    Tools.run();
  }

  void callField() {
    Tools.run();
  }
}
