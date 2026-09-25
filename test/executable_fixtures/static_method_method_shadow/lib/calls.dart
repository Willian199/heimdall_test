class Tools {
  static void run() {}
}

class Action {}

extension RunOnActionFactory on Action Function() {
  Action run() => this();
}

class Consumer {
  Action Tools() => Action();

  void callMethodTearoff() {
    Tools.run();
  }

  void callLocalFunctionTearoff() {
    Action Tools() => Action();
    Tools.run();
  }
}

class BaseConsumer {
  Action Tools() => Action();
}

class InheritedConsumer extends BaseConsumer {
  void callInheritedMethodTearoff() {
    Tools.run();
  }

  Action callSwitchExpressionTearoff(Action Function() value) =>
      switch (value) {
        var Tools => Tools.run(),
      };

  Action callCollectionIfTearoff(Action Function() value) =>
      [if (value case var Tools) Tools.run()].single;

  Action callCollectionForTearoff(Iterable<Action Function()> values) =>
      [for (final Tools in values) Tools.run()].single;
}
