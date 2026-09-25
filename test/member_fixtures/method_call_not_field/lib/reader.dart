class Reader {
  void value() {}

  void callValue() {
    value();
  }
}

class PatternReader {
  int name = 0;

  void callPattern((int, int) pair) {
    for (var (name, _) in [pair]) {
      print(name);
    }
  }

  List<int> callIfCollectionPattern(Object value) => [
    if (value case int name) name,
  ];

  List<int> callForCollectionPattern(List<(int, int)> pairs) => [
    for (var (name, _) in pairs) name,
  ];
}

class CollectionScopeReader {
  int value = 1;

  List<int> readFieldAfterCollectionLoop(List<int> values) => [
    for (final value in values) value,
    value,
  ];
}

class ForEachIterableScopeReader {
  final List<int> values = const [1];

  void iterateFieldBeforeLoopBinding() {
    for (final values in values) {
      print(values);
    }
  }
}

class CStyleLoopScopeReader {
  int index = 1;

  void readFieldAfterLoop() {
    for (var index = 0; index < 1; index++) {}
    print(index);
  }
}

class SwitchPatternReader {
  int name = 1;

  void readStatementPattern(Object value) {
    switch (value) {
      case int name:
        print(name);
    }
  }

  List<int> readExpressionPattern(Object value) => switch (value) {
    int name => [name],
    _ => [],
  };

  void readBoundNameInGuard((int, int) value) {
    switch (value) {
      case (var name, _) when name > 0:
        print(name);
    }
  }
}

class LocalRecordPatternReader {
  int name = 1;

  void readLocalPattern((int, int) pair) {
    var (name, _) = pair;
    print(name);
  }
}

class ForEachListPatternReader {
  int name = 1;

  void readListPattern(List<List<int>> values) {
    for (final [name] in values) {
      print(name);
    }
  }
}

class SwitchMapPatternReader {
  int name = 1;

  void readMapPattern(Object value) {
    switch (value) {
      case {'name': int name}:
        print(name);
    }
  }
}

class NamedArgumentReader {
  int value = 1;

  void sink({required int value}) {}

  void callWithoutReadingField() {
    sink(value: 2);
  }

  void callWithoutReadingFieldInRecord() {
    final record = (value: 2);
    print(record);
  }
}

class CatchStackTraceFieldReader {
  int stack = 1;
  int failure = 1;

  void readCatchStackTrace() {
    try {
      throw StateError('unavailable');
    } catch (error, stack) {
      print(stack);
    }
  }

  void readCatchException() {
    try {
      throw StateError('unavailable');
    } catch (failure) {
      print(failure);
    }
  }
}

class ForPatternReader {
  int name = 1;

  void readForPattern((int, int) pair) {
    for (var (name, _) = pair; name < 1; name++) {
      print(name);
    }
  }
}

class OtherValue {
  int value = 0;
}

class ForeignFieldWriteReader {
  int value = 1;

  void writeOther(OtherValue other) {
    other.value = 2;
  }

  void writeOtherThroughCascade(OtherValue other) {
    other..value = 2;
  }
}
