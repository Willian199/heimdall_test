import 'lib/async.dart';
import 'lib/filtered.dart';
import 'lib/implicit.dart';
import 'lib/package.dart';
import 'lib/part_owner.dart';
import 'lib/prefixed.dart';
import 'lib/reexported.dart';
import 'lib/shadowed.dart';

void main() {
  AsyncConsumer();
  FilteredConsumer();
  ImplicitConsumer();
  PackageConsumer();
  PartOwner();
  PartConsumer();
  PrefixedConsumer();
  ReexportedConsumer();
  ShadowedConsumer();
}
