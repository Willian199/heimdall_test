class Tools {
  static void run() {}
}

class Action {
  void run() {}
}

class Host {
  final Action Tools = Action();
}

mixin Runner on Host {
  void call() {
    Tools.run();
  }
}
