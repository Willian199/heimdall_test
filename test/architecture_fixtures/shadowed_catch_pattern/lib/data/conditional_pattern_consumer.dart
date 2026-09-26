// ignore: unused_import
import '../model/foo.dart' if (dart.library.html) '../model/foo_web.dart';
import '../model/foo.dart'
    if (dart.library.html) '../model/foo_web.dart'
    as models;

class Action {}

extension UseActionFactory on Action Function() {
  Action use() => this();
}

Action Function() get Foo =>
    () => Action();

class SwitchExpressionPatternConsumer {
  Action consume(Action Function() value) => switch (value) {
    var Foo => Foo.use(),
  };
}

class CollectionIfPatternConsumer {
  Action consume(Action Function() value) =>
      [if (value case var Foo) Foo.use()].single;
}

class CollectionForVariableConsumer {
  Action consume(Iterable<Action Function()> values) =>
      [for (final Foo in values) Foo.use()].single;
}

class ForInVariableConsumer {
  void consume(Iterable<Action Function()> values) {
    for (final Foo in values) {
      Foo.use();
    }
  }
}

class ForInRecordPatternConsumer {
  void consume(Iterable<(Action Function(), int)> values) {
    for (final (Foo, _) in values) {
      Foo.use();
    }
  }
}

class CatchStackTraceConsumer {
  void consume() {
    try {
      throw StateError('unavailable');
    } catch (error, Foo) {
      Foo.toString();
    }
  }
}

class SwitchStatementPatternConsumer {
  Action consume(Action Function() value) {
    switch (value) {
      case var Foo:
        return Foo.use();
    }
  }
}

class GenericFunctionTypeShadowConsumer {
  void consume(void Function<Foo>(Foo) callback) {}
}

class GenericFunctionReturnShadowConsumer {
  void consume(Foo Function<Foo>() callback) {}
}

class TopLevelGetterReceiverConsumer {
  Action consume() => Foo.use();
}

class ConstructorInitializerDependencyConsumer {
  final Object value;

  ConstructorInitializerDependencyConsumer() : value = models.Foo();
}

class ConstructorAssertDependencyConsumer {
  ConstructorAssertDependencyConsumer() : assert(models.Foo().hashCode >= 0);
}

class RedirectingInitializerDependencyConsumer {
  final Object value;

  RedirectingInitializerDependencyConsumer() : this.named(models.Foo());

  RedirectingInitializerDependencyConsumer.named(this.value);
}

class StaticInitializerDependencyConsumer {
  final Object value;

  StaticInitializerDependencyConsumer() : value = models.Foo.make();
}

class ListPatternReceiverConsumer {
  Action consume(Iterable<List<Action Function()>> values) {
    for (final [Foo] in values) {
      return Foo.use();
    }
    return Action();
  }
}

class MapPatternReceiverConsumer {
  Action consume(Map<String, Action Function()> values) {
    switch (values) {
      case {'action': var Foo}:
        return Foo.use();
      default:
        return Action();
    }
  }
}

class GuardedSwitchPatternReceiverConsumer {
  Action consume(Action Function() value) => switch (value) {
    var Foo when Foo.use().hashCode >= 0 => Foo.use(),
    _ => Action(),
  };
}
