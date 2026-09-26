import 'dart:async';
import 'dart:convert' as convert;
import 'package:bug_hunt_fixture/models.dart' show BaseEntity, ChildEntity, EntityAlias;
import 'models.dart' as model;
import 'models.dart' hide EmptyType;

class Consumer {
  final EntityAlias entity;
  Consumer(this.entity);

  Future<String> load() async {
    final value = model.ChildEntity.build('id');
    final encoded = convert.jsonEncode(value.id);
    await Future<void>.value();
    return encoded;
  }

  BaseEntity copy(String id) => ChildEntity(id, 1);
  List<BaseEntity> list() => <BaseEntity>[];
}

class GenericConsumer<T> {
  T echo(T value) => value;
}
