import 'types.dart';

class StaticBaseConsumer {
  static final Action Tools = Action();
}

class StaticInheritedConsumer extends StaticBaseConsumer {
  void callStaticInherited() {
    Tools.run();
  }
}
