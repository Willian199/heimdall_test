import 'tools.dart';

extension RunOnActionFactory on Action Function() {
  Action run() => this();
}

Action Function() get Tools =>
    () => Action();

class GetterConsumer {
  Action callGetterTearoff() => Tools.run();
}
