import 'types.dart';

class ActualDynamic extends DynamicMiddle with Logging {}
class PartialCounter extends Base<int, String> with Partial {}
class ExplicitDynamic extends Base<dynamic, String> with Logging<dynamic, String> {}
class RawPlain with Plain {}
class NestedDynamic extends Base<List<dynamic>, String> with Nested {}
class RecordDynamic extends Base<(int, {dynamic value}), String> with Recorded {}
class ChainDynamic extends DynamicMiddle with Bridge, Following {}
class AliasedDynamic extends DynamicMiddle with LoggingAlias {}
class CallbackDynamic extends Base<dynamic Function(), String> with Callback {}
class AliasRecordDynamic extends Base<DynamicRecord, String> with Recorded {}
class PatternRecordDynamic extends Base<DynamicRecord, String> with AliasedRecord {}
class SharedAliasRecordDynamic extends Base<RecordPattern<dynamic>, String> with AliasedRecord {}

class DynamicOverrides extends DynamicMiddle with Logging {
  @override
  read() => 1;
}

final inheritedDynamic = ActualDynamic().read();

mixin MixedConstraints<T> on Base<T, String>, Iterable<T> {}
abstract class MixedBase extends Base<dynamic, String> implements Iterable<dynamic> {}
abstract class MixedDynamic extends MixedBase with MixedConstraints {}
