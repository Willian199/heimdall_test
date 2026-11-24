import 'barrel.dart' as api;
import 'types.dart';

class Counter extends Base<int, String> with Logging {}
class Explicit extends Base<int, String> with Logging<int, String> {}
class Indirect extends Middle<int> with Logging {}
class Generic<T> extends Middle<T> with Logging {}
class Alias = Base<int, String> with Logging;
class Prefixed extends api.Base<int, String> with api.Logging {}
class AliasedBase extends api.BaseAlias<int> with api.Logging {}
class AliasedMixin extends Base<int, String> with api.LoggingAlias<int> {}
class Chained extends Base<int, String> with Bridge, Following {}
class NestedCounter extends Base<List<int>, String> with Nested {}
class RecordCounter extends Base<(int, {String value}), String> with Recorded {}
class BoundCounter extends Base<int, String> with Bounded {}
class ChainedChild extends Chained with Following {}
class InterfaceCounter extends InterfaceBase<int> with Logging {}
class MultipleCounter extends Composite<int> with Multiple {}
class CallbackCounter extends Base<int Function(), String> with Callback {}
class AliasRecordCounter extends Base<SafeRecord, String> with Recorded {}
class PatternRecordCounter extends Base<SafeRecord, String> with AliasedRecord {}
class SharedAliasRecordCounter extends Base<RecordPattern<int>, String> with AliasedRecord {}
class ShadowedParameter<DynamicRecord> extends Base<DynamicRecord, String> with Logging {}

mixin IterableLogging<T> on Iterable<T> {}
abstract class SdkCounter extends Iterable<int> with IterableLogging {}

class Overrides extends Base<int, String> with Logging {
  @override
  read() => 1;

  @override
  void accept(value) {}
}

final inherited = Counter().read();
