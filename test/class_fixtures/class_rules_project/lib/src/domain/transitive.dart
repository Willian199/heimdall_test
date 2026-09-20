class GrandParent {}

typedef GrandParentAlias = GrandParent;

class Parent extends GrandParentAlias {}

class Child extends Parent {
  void loadChild() {}
}

abstract interface class RootGateway {}

typedef RootGatewayAlias = RootGateway;

abstract interface class GatewayParent implements RootGatewayAlias {}

class GatewayChild extends GatewayParent {
  void fetchGateway() {}
}

mixin SharedBehavior {}

typedef SharedBehaviorAlias = SharedBehavior;

mixin ExtraBehavior {}

class MixinParent with SharedBehaviorAlias, ExtraBehavior {}

class MixinChild extends MixinParent {
  void auditChild() {}
}

class SuperBase {
  String inheritedName = '';

  String normalize(String value) => value.trim();
}

class SuperChild extends SuperBase {
  String callSuper(String value) => super.normalize(value);

  String readSuper() => super.inheritedName;
}
