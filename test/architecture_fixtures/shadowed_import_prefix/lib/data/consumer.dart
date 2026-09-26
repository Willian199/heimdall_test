import '../domain/foo.dart' as domain;

class Carrier {
  domain.Foo get Foo => domain.Foo();
}

class Consumer {
  String describe() {
    final domain = Carrier();
    return domain.Foo.toString();
  }
}

class ParameterConsumer {
  String describe(Carrier domain) => domain.Foo.toString();
}

class FieldConsumer {
  final domain = Carrier();

  String describe() => domain.Foo.toString();
}

class MethodCarrier {
  Object Foo() => Object();
}

class MethodConsumer {
  Object create() {
    final domain = MethodCarrier();
    return domain.Foo();
  }
}

class DirectConsumer {
  Object create() => domain.Foo();
}

class ScopeConsumer {
  Object create() {
    {
      final domain = Carrier();
      domain.Foo.toString();
    }
    return domain.Foo();
  }
}
