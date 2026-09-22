import 'types.dart';

List<dynamic> list() => throw 0;
Map<dynamic, String> mapKey() => throw 0;
Map<String, dynamic> mapValue() => throw 0;
Set<dynamic> set() => throw 0;
Iterable<dynamic> iterable() => throw 0;
List<Box<dynamic>> nested() => throw 0;
List<Box> rawNested() => throw 0;
List<dynamic Function()> callbackList() => throw 0;
(String, dynamic) positional() => throw 0;
({int id, dynamic value}) named() => throw 0;
void recordParameter((int, List<dynamic>) value) {}
Identifier safeAlias() => throw 0;
Payload payload() => throw 0;
Chain chain() => throw 0;
Callback callback() => throw 0;
LegacyCallback legacyCallback() => throw 0;
Pair recordAlias() => throw 0;
Typed<int> typedAlias() => throw 0;
AlwaysDynamic<int> hiddenDynamic() => throw 0;
CycleA cyclic() => throw 0;
T shadowed<T>(T value) => value;
List<Box<int>> safeNested() => throw 0;
(int, {String name}) safeRecord() => throw 0;
