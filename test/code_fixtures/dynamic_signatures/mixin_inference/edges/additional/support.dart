import '../support.dart';
export '../support.dart';

mixin Empty<T> on WideBase<T> {}
mixin GetterOnly<T> on WideBase<T> {
  @override
  T get value => 1 as T;
}
mixin MethodOnly<T> on WideBase<T> {
  @override
  T read() => 1 as T;
}

abstract interface class ReadContract<T> {
  T read();
}

abstract interface class AcceptContract<T> {
  void accept(T next);
}

abstract interface class WriteContract<T> {
  set output(T next);
}

class Narrow {
  void accept(int next) {}
  set output(int next) {}
}

typedef Phantom<T> = int;

class Repeated<A, B> {}

typedef Drop<A, B> = Repeated<A, A>;

class Captured<A, B> {}

mixin PhantomAccess<T> on HeaderBox<Phantom<T>> {
  Type get inferred => T;
}
mixin DroppedAccess<T, U> on HeaderBox<Drop<T, U>> {
  Type get inferred => Captured<T, U>;
}
mixin RepeatedAccess<T> on HeaderBox<Repeated<T, T>> {
  Type get inferred => T;
}
mixin GenericClosure<T> on HeaderBox<T Function<R>(R)> {
  Type get inferred => T;
}
mixin NamedClosure<T> on HeaderBox<T Function<R extends num>({required R value})> {
  Type get inferred => T;
}
mixin OptionalClosure<T> on HeaderBox<T Function<R>([R? value])> {
  Type get inferred => T;
}
mixin TopDefault<T, U extends Object?> on HeaderBox<T> {
  Type get inferred => U;
}

class _Hidden<T> {}

class PublicPrivate<T> extends _Hidden<T> {}

mixin PrivateAccess<T> on _Hidden<T> {
  Type get inferred => T;
}

class ListCell<T> extends Cell<List<T>> with Members {
  ListCell(super.value);
}
