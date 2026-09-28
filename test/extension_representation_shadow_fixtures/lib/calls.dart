class Tools {
  static void go() {}
}

class Thing {
  void go() {}
}

extension type Example(Thing Tools) {
  void call() {
    Tools.go();
  }
}
