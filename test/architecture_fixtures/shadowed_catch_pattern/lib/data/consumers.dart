import '../model/foo.dart';

Object Foo() => Object();

class CatchConsumer {
  void consume() {
    try {
      throw StateError('unavailable');
    } catch (Foo) {
      Foo.toString();
    }
  }
}

class PatternConsumer {
  void consume(Object value) {
    if (value case var Foo) {
      Foo.toString();
    }
  }
}

extension type GenericParameterConsumer<Foo>(Foo value) {
  Foo get current => value;
}

class GetterConsumer {
  Object get Foo => Object();

  void consume() {
    Foo.toString();
  }
}

class MethodReceiverConsumer {
  Object Foo() => Object();

  void consume() {
    Foo.toString();
  }
}

class TopLevelFunctionReceiverConsumer {
  void consume() {
    Foo.toString();
  }
}

extension type RepresentationShadowConsumer(int Foo) {
  void consume() {
    Foo.toString();
  }
}
