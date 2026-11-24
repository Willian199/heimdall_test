import 'contracts.dart';

class AbstractLeaf extends AbstractHop<int> with Access, Observe, FacadeAccess {
  AbstractLeaf(super.value);
}

class GenericLeaf<T> extends AbstractHop<T> with Access, Observe, FacadeAccess {
  GenericLeaf(super.value);
}

class MixinClassLeaf extends StoreBase<String> with StoreMixin<String>, Access, Observe {
  MixinClassLeaf(super.value);
}

abstract interface class InterfaceApplication<T> extends AbstractStore<T> with Access, Observe {}

class ImplementsApplication extends StoreBase<int> with Access, Observe implements InterfaceApplication<int> {
  ImplementsApplication(super.value);
}

class NamedApplication = InterfaceStore<String> with Access, Observe, FacadeAccess;

abstract class AbstractAccess<T> extends AbstractStore<T> with Access {
  @override
  fetch();

  @override
  get current;

  @override
  set current(next);

  @override
  void replace(next);
}

class ImplementsAbstractAccess extends StoreBase<int> with Access implements AbstractAccess<int> {
  ImplementsAbstractAccess(super.value);
}

class DynamicInterfaceStore extends InterfaceStore<dynamic> {
  DynamicInterfaceStore(super.value);
}

class DynamicAbstractLeaf extends DynamicInterfaceStore with Access, Observe, FacadeAccess {
  DynamicAbstractLeaf(super.value);
}
