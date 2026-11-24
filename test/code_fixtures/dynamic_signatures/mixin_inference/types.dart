class Base<E, S> {}

mixin Logging<E, S> on Base<E, S> {
  (Type, Type) get types => (E, S);
  E read() => throw 0;
  void accept(S value) {}
}

mixin Partial<E, Unused> on Base<E, String> {}

mixin Bounded<E, Extra extends num> on Base<E, String> {}

class Carrier<T> {}

mixin Bridge<T> on Base<T, String> implements Carrier<T> {}

mixin Following<T> on Carrier<T> {}

mixin Nested<T> on Base<List<T>, String> {}

mixin Recorded<T> on Base<(int, {T value}), String> {}

mixin Plain<T> {}

typedef BaseAlias<T> = Base<T, String>;
typedef LoggingAlias<T> = Logging<T, String>;

class Middle<T> extends Base<T, String> {}

class DynamicMiddle extends Base<dynamic, String> {}

class InterfaceBase<T> implements Base<T, String> {}

class Composite<T> extends Base<T, String> implements Carrier<T> {}

mixin Multiple<E, S> on Base<E, S>, Carrier<E> {}

mixin Callback<T> on Base<T Function(), String> {}

typedef SafeRecord = (int, {String value});
typedef DynamicRecord = (int, {dynamic value});

typedef RecordPattern<T> = (int, {T value});
mixin AliasedRecord<T> on Base<RecordPattern<T>, String> {}
