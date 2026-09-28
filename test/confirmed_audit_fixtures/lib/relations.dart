class NamedCopy {
  NamedCopy.named({required this.value});
  final int value;
  NamedCopy copyWith({required int value}) => NamedCopy.named(value: value);
}

class NewCopy {
  NewCopy({required this.value});
  final int value;
  NewCopy copyWith({required int value}) => NewCopy.new(value: value);
}

class ShadowCopy {
  ShadowCopy({required this.value});
  final int value;
  ShadowCopy copyWith({required int value}) {
    dynamic ShadowCopy({required int value}) => this;
    return ShadowCopy(value: value);
  }
}

class ThrowList {
  final int value = 1;
  List<int> props(bool ok) => ok ? [value] : throw StateError('stop');
}

class ThrowCopy {
  ThrowCopy({required this.value});
  final int value;
  ThrowCopy copyWith({required int value, bool ok = true}) => ok ? ThrowCopy(value: value) : throw StateError('stop');
}

class FinallyCopy {
  FinallyCopy({required this.value});
  final int value;
  FinallyCopy copyWith({required int value}) {
    try {
      return this;
    } finally {
      return FinallyCopy(value: value);
    }
  }
}
