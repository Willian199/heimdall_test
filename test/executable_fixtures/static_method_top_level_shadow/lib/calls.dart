import 'tools.dart';

extension RunOnActionFactory on Action Function() {
  Action run() => this();
}

Action Tools() => Action();

class Consumer {
  Action callFunctionTearoff() => Tools.run();
}
