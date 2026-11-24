import 'contracts.dart';

class TypedOverrides extends StoreBase<int> with Access {
  TypedOverrides(super.value);

  @override
  fetch() => read();

  @override
  get current => value;

  @override
  set current(next) => value = next;

  @override
  void replace(next) => write(next);
}

class DynamicOverrides extends DynamicStore with Access {
  DynamicOverrides(super.value);

  @override
  fetch() => read();

  @override
  get current => value;

  @override
  set current(next) => value = next;

  @override
  void replace(next) => write(next);
}
