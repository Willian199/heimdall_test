library repeated;

import '../support.dart' as shared;
part 'right_part.dart';

class Model<T> extends _Root<T> {}

mixin Inspect<T> on shared.HeaderBox<T> {
  Type get inferred => T;
  T read() => 1 as T;
}
typedef ModelAlias<T> = Model<T>;
