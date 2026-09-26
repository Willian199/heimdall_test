abstract class BaseEntity {
  final String id;
  const BaseEntity(this.id);
}

interface class Contract {
  const Contract();
}

mixin Auditable {
  DateTime get createdAt => DateTime(2020);
}

class ChildEntity extends BaseEntity with Auditable implements Contract {
  final int count;
  int mutableCount = 0;
  int? nullableCount;
  static const String kind = 'child';
  static int instances = 0;

  ChildEntity(super.id, this.count);
  ChildEntity.named(super.id, this.count);

  String describe([String prefix = '']) => '$prefix$id';
  static ChildEntity build(String id) => ChildEntity(id, 1);
}

class EmptyType {}

class ShadowedPatternType {}

class StaticOnly {
  static const int value = 1;
  static void reset() {}
}

class PublicFields {
  final int id = 1;
  String name = 'name';
}

class PrivateFields {
  final int _id = 1;
  String _name = 'name';
}

enum ResultKind { ok, error }

extension NamedStringExtension on String {
  String tagged() => this;
}

extension type UserId(int value) {
  UserId.fromInt(int value) : this(value);
  String get text => '$value';
}

typedef EntityAlias = BaseEntity;

void topLevelFunction(String value) {}
final topLevelValue = 1;
final _privateTopLevelValue = 2;
