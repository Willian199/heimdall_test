abstract interface class AuditContract {}

mixin AuditContractMixin implements AuditContract {}

class DirectMixinWorker with AuditContractMixin {}

class ParentMixinWorker with AuditContractMixin {}

class ChildMixinWorker extends ParentMixinWorker {}

class AliasMixinWorker = Object with AuditContractMixin;

enum EnumMixinWorker with AuditContractMixin { one }

class Product {}

class ConstructorLookalike {
  void Product() {}

  void invokeMethod() {
    Product();
  }
}

class ProducedValue {
  const ProducedValue([int seed = 0]);
}

class DefaultConstructorFactory {
  Object create({Object value = const ProducedValue(1)}) => value;
}

class DefaultConstructorParameter {
  DefaultConstructorParameter({Object value = const ProducedValue(1)});
}
