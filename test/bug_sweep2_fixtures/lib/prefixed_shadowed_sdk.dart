import 'shadowed_sdk.dart' as custom;

final safePrefixedList = () => new custom.List.from(<dynamic>[]);
final safePrefixedFuture = () => custom.Future.sync(() => 1);
