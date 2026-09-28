import 'dart:core' as core;
import 'dart:core';

class Object {}

class Never {}

class ShadowTypes {
  late String text;
  late Never userNever;
  late core.int number;
  late core.Null nil;
  late core.Never bottom;
  late core.List<core.Null> nils;
}

class DependentBounds<T extends core.num, U extends T> {}

class BoundCases {
  late DependentBounds raw;
  late core.int Function(core.int) narrow;
  late core.List<core.int Function(core.int)> callbacks;
  late core.List<(core.int,)> records;
}

typedef IncompatibleCallback = core.String Function();
