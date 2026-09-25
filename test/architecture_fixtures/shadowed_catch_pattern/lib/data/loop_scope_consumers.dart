import '../model/foo.dart';

class LoopScopeConsumer {
  void consume(Iterable<Object> values) {
    for (final Foo in values) {}
    Foo();
  }
}

class CStyleForScopeConsumer {
  void consume() {
    for (var Foo = 0; Foo < 1; Foo++) {}
    Foo();
  }
}
