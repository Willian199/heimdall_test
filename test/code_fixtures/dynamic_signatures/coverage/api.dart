var missingType;
final explicitInitializer = <dynamic>[];
final emptyCollection = [];
final safeInitializer = <int>[];
dynamic _private = 0, publicValue = 0;
void wildcard(dynamic _) {}
void nestedWildcard(void Function(dynamic _) callback) {}
void callback(Function(int) value) {}
void legacyCallback(value(int count)) {}
void bound<T extends dynamic>() {}

class Box<T> {}

class NumberBox<T extends num> {}

NumberBox boundedRaw() => throw 0;

class Api extends Box<dynamic> {}

extension type Wrapper(dynamic value) {}

class Base<T> {
  Base(this.value);
  final T value;
}

class Child extends Base<dynamic> {
  Child(super.value);
}

class TypedChild extends Base<int> {
  TypedChild(super.renamed);
}

class InferredField {
  InferredField(this.value);
  InferredField.named(this.value);
  var value;
}

class Parent {
  void accept(int value) {}
  List<int> safeReturn() => [];
}

class Override extends Parent {
  @override
  void accept(value) {}
  void own(value) {}
  @override
  safeReturn() => [];
}

class DynamicParent<T> {
  void accept(T value) {}
}

class DynamicOverride extends DynamicParent<dynamic> {
  @override
  void accept(value) {}
}

class TypedOverride extends DynamicParent<int> {
  @override
  void accept(renamed) {}
}

typedef NumberAlias<T extends num> = NumberBox<T>;
NumberAlias boundedAlias() => throw 0;

class GenericExtension<T> {}

extension Extra on GenericExtension<dynamic> {}

mixin Contract<T> {}

class WithContract with Contract<dynamic> {}

class ImplementsContract implements Contract<dynamic> {}

final recordInitializer = (1, <dynamic>[]);
final callbackInitializer = (value) => value;
final aliasInitializer = explicitInitializer;
final safeScalar = 42;

class SafeBox<T> {
  final T value;
  SafeBox(this.value);
}

final inferredConstructor = SafeBox(42);
typedef BareCallback = Function(int);
BareCallback callbackAlias() => throw 0;
dynamic shadow;
safeParameter(int shadow) => shadow;
safeLocal() {
  final shadow = 1;
  return shadow;
}

inferredDynamicReturn(value) => value;
typedef BaseAlias<T> = Base<T>;

class AliasedChild extends BaseAlias<dynamic> {
  AliasedChild(super.value);
}

class ForwardBound<T extends Box<U>, U> {}

ForwardBound forwardBound() => throw 0;
typedef _CycleA = _CycleB;
typedef _CycleB = _CycleA;
_CycleA cycle() => throw 0;
