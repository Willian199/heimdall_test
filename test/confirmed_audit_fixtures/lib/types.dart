import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

class TypeCases<T extends num> {
  late List<int> list;
  late Set<int> set;
  late Queue<int> queue;
  late HashSet<int> hashSet;
  late HashMap<String, int> hashMap;
  late Uint8List bytes;
  late int integer;
  late String string;
  late Future<int> future;
  late Null nil;
  late void nothing;
  late T bounded;
  late (int, String) record;
  late ({int a, String b}) namedRecord;
  late int Function(num) function;
  late List listRaw;
  late int? nullableInt;
  late List<void> voidList;
  late List<Null> nullList;
}

class Parent<T> {
  Parent(T original);
}

class Renamed extends Parent<int> {
  Renamed(super.renamed);
}

class RawParent<T extends num> {
  RawParent(T value);
}

class RawChild extends RawParent {
  RawChild(super.value);
}

class BoundedMember {
  void accept<T extends num>(T value) {}
}

abstract interface class Contract<T> {}

class GenericImplementation implements Contract<int> {}

mixin GenericMixin<T> {}

class GenericMixed with GenericMixin<int> {}

class GenericExtended extends Parent<int> {
  GenericExtended(super.original);
}

mixin Constrained on Parent<int> {}
extension type const Primary(int value) {}
extension type const HiddenPrimary._(int value) {}
extension type const NamedPrimary.named(int value) {}
extension type NullableRepresentation(Object? value) {}

typedef Callback = int Function(num);

class AliasCases {
  late Callback callback;
}

class NullabilityCases {
  late Null nil;
  late int integer;
}
