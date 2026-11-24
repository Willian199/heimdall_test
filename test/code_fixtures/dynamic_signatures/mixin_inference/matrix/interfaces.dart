import 'contracts.dart';

abstract interface class InferredInterface<T> implements Store<T> {
  @override
  read();

  @override
  get value;

  @override
  set value(next);

  @override
  void write(next);
}

class InterfaceOverrides extends StoreBase<int> implements InferredInterface<int> {
  InterfaceOverrides(super.value);

  @override
  read() => super.read();

  @override
  get value => super.value;

  @override
  set value(next) => super.value = next;

  @override
  void write(next) => super.write(next);
}

abstract interface class DynamicInterface implements Store<dynamic> {
  @override
  read();

  @override
  get value;

  @override
  set value(next);

  @override
  void write(next);
}
