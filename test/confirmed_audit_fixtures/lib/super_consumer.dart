import 'helpers.dart' as child_scope;
import 'super_scope.dart';

class ScopedChild extends ScopedParent {
  ScopedChild(super.item);
  child_scope.Holder? holder;
}
