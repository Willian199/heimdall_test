import 'contracts.dart';

class Pair<A, B> {}
class Reordered<A, B> extends Pair<B, List<A?>> {}

mixin PairAccess<K, V> on Pair<K, V> {
  (Type, Type) get pairTypes => (K, V);
}

class ReorderedSafe extends Reordered<int, String> with PairAccess {}
class ReorderedDynamic extends Reordered<dynamic, String> with PairAccess {}

mixin Dependent<T, U extends List<T>> on Store<T> {
  (Type, Type) get dependentTypes => (T, U);
}

class DependentSafe extends StoreBase<int> with Dependent {
  DependentSafe(super.value);
}

class DependentDynamic extends DynamicStore with Dependent {
  DependentDynamic(super.value);
}

typedef Payload<T> = Map<String, List<T?>>;

mixin PayloadAccess<T> on Store<Payload<T>> {
  Type get payloadType => T;
}

class PayloadSafe extends StoreBase<Payload<int>> with PayloadAccess {
  PayloadSafe(super.value);
}

class PayloadDynamic extends StoreBase<Payload<dynamic>> with PayloadAccess {
  PayloadDynamic(super.value);
}

mixin NullableAccess<T extends Object?> on Store<T?> {
  Type get nullableType => T;
}

class NullableSafe extends StoreBase<int?> with NullableAccess {
  NullableSafe(super.value);
}

class NullableDynamic extends DynamicStore with NullableAccess {
  NullableDynamic(super.value);
}

mixin BoundedAccess<T extends num> on Store<T> {
  Type get numberType => T;
}

class BoundedSafe extends StoreBase<int> with BoundedAccess {
  BoundedSafe(super.value);
}

mixin FactoryAccess<T> on Store<T Function()> {
  Type get resultType => T;
}

class FactorySafe extends StoreBase<int Function()> with FactoryAccess {
  FactorySafe(super.value);
}

class FactoryDynamic extends StoreBase<dynamic Function()> with FactoryAccess {
  FactoryDynamic(super.value);
}
