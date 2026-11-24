abstract interface class Readable<T> {
  T read();
  T get value;
}

abstract interface class Writable<T> {
  void write(T value);
  set value(T value);
}

abstract interface class Store<T> implements Readable<T>, Writable<T> {}

abstract class AbstractStore<T> implements Store<T> {}

class StoreBase<T> extends AbstractStore<T> {
  StoreBase(this._value);

  T _value;

  @override
  T read() => _value;

  @override
  T get value => _value;

  @override
  set value(T next) => _value = next;

  @override
  void write(T next) => _value = next;
}

mixin Access<T> on Store<T> {
  Type get argumentType => T;
  T fetch() => read();
  T get current => value;
  set current(T next) => value = next;
  void replace(T next) => write(next);
  R identity<R>(R next) => next;
  R named<R>({required R next}) => next;
  R optional<R>([R? next]) => next as R;
  Y second<X, Y>(X first, Y next) => next;
  List<R> wrap<R>(R next) => [next];
  T shadow<T>(T next) => next;
  Type inferredType<R>(R next) => R;
}

mixin Observe<T> on Readable<T>, Writable<T> {
  Type get observedType => T;
}

abstract interface class Facade<T> implements Store<T> {}

mixin FacadeAccess<T> on Facade<T> {
  Type get facadeType => T;
}

class InterfaceStore<T> extends StoreBase<T> implements Facade<T> {
  InterfaceStore(super.value);
}

abstract class AbstractHop<T> extends InterfaceStore<T> {
  AbstractHop(super.value);
}

abstract mixin class StoreMixin<T> implements Store<T> {}

class TypedStore extends StoreBase<int> with Access {
  TypedStore(super.value);
}

class DynamicStore extends StoreBase<dynamic> with Access {
  DynamicStore(super.value);
}
