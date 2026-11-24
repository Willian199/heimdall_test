import 'dart:async';

Type typeOf<T>() => T;
Type typeOfValue<T>(T value) => T;

class HeaderBox<T> {}

mixin HeaderAccess<T> on HeaderBox<T> {
  Type get inferred => T;
}

class Hop<T> extends HeaderBox<T> {}

class Hop2<T> extends Hop<T> {}

abstract interface class HeaderContract<T> implements HeaderBox<T> {}

class Implementation<T> implements HeaderContract<T> {}

abstract class AbstractHop<T> extends Implementation<T> {}

class ConcreteHop<T> extends AbstractHop<T> {}

interface class InterfaceHop<T> extends Hop2<T> {}

class InterfaceImplementation<T> implements InterfaceHop<T> {}

abstract interface class Right<T> implements HeaderBox<T> {}

class Diamond<T> extends Implementation<T> implements Right<T> {}

abstract interface class Extra<T> {}

class Composite<T> extends Hop<T> implements Extra<T> {}

mixin Carrier<T> implements HeaderBox<T> {}
mixin Prior<T> on HeaderBox<T> implements Extra<T> {}
mixin FromExtra<T> on Extra<T> {
  Type get inferred => T;
}
mixin FromAccess<T> on HeaderAccess<T> {
  Type get recovered => T;
}
mixin Multiple<T> on HeaderBox<T>, Extra<T> {
  Type get inferred => T;
}
typedef BoxAlias<T> = Hop2<T>;
typedef AliasChain<T> = BoxAlias<T>;
typedef RecordAlias<T> = (int, {T value});
typedef ReorderedAlias<A, B> = Map<B, List<A>>;

mixin Unbounded<T, U> on HeaderBox<T> {
  Type get inferred => U;
}
mixin Bounded<T, U extends num> on HeaderBox<T> {
  Type get inferred => U;
}
mixin Dependent<T, U extends List<T>> on HeaderBox<T> {
  Type get inferred => U;
}
mixin ChainedBounds<T, U extends List<T>, V extends Map<String, U>> on HeaderBox<T> {
  Type get inferred => V;
}
mixin Nullable<T extends Object?> on HeaderBox<T> {
  Type get inferred => T;
}
typedef Shadow = dynamic;

class ShadowHop<Shadow> extends HeaderBox<Shadow> {}

abstract interface class CellView<T> {
  T read();
  T get value;
  set value(T next);
}

class Cell<T> implements CellView<T> {
  Cell(this._value);
  T _value;
  @override
  T read() => _value;
  @override
  T get value => _value;
  @override
  set value(T next) => _value = next;
}

mixin Members<T> on Cell<T> {
  T fetch() => read();
  T get current => value;
  set current(T next) => value = next;
  void replace(T next) => value = next;
  R identity<R>(R next) => next;
  R named<R>({required R next}) => next;
  R optional<R>([R? next]) => next as R;
  List<R> wrap<R>(R next) => [next];
  Y second<X, Y>(X first, Y next) => next;
}

class TypedCell extends Cell<int> with Members {
  TypedCell(super.value);
}

class DynamicCell extends Cell<dynamic> with Members {
  DynamicCell(super.value);
}

class WideBase<T> {
  dynamic read() => 1;
  dynamic get value => 1;
  set value(dynamic next) {}
}

mixin Refine<T> on WideBase<T> {
  @override
  T read() => 1 as T;
  @override
  T get value => 1 as T;
  @override
  set value(covariant T next) {}
}
mixin Earlier<T> on WideBase<T> {
  @override
  dynamic read() => 1;
}

mixin Shape0<T> on HeaderBox<List<T>> {
  Type get inferred => T;
}

mixin Shape1<T> on HeaderBox<Map<String, T>> {
  Type get inferred => T;
}

mixin Shape2<T> on HeaderBox<Map<T, int>> {
  Type get inferred => T;
}

mixin Shape3<T> on HeaderBox<(T, int)> {
  Type get inferred => T;
}

mixin Shape4<T> on HeaderBox<(int, {T value})> {
  Type get inferred => T;
}

mixin Shape5<T> on HeaderBox<T Function()> {
  Type get inferred => T;
}

mixin Shape6<T> on HeaderBox<List<T> Function()> {
  Type get inferred => T;
}

mixin Shape7<T> on HeaderBox<void Function(void Function(T))> {
  Type get inferred => T;
}

mixin Shape8<T> on HeaderBox<RecordAlias<T>> {
  Type get inferred => T;
}

mixin Shape9<T> on HeaderBox<ReorderedAlias<T, String>> {
  Type get inferred => T;
}
