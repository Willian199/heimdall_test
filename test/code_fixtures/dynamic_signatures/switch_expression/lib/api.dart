dynamic _dynamicValue() => 1;
dynamic _slot;
dynamic _dynamicIterable;
dynamic _dynamicRecord = (1, 2);
dynamic _dynamicMap = {'value': 1};
dynamic _dynamicList = [1];
dynamic _dynamicRecords = [(1, 2)];
Stream<dynamic> _dynamicStream = Stream<dynamic>.empty();
List<dynamic> _dynamicListValues = [];
Iterable<dynamic> _dynamicIterableValues = [];
Set<dynamic> _dynamicSetValues = {};
Map<String, dynamic> _dynamicMapValues = {};
Map<dynamic, String> _dynamicKeyValues = {};
Iterator<dynamic> _dynamicIteratorValues = [].iterator;

class _Box<T> {
  _Box(this.value);
  final T value;
}

final _Box<dynamic> Function(int) _boxFactory = _Box<dynamic>.new;

inferFromSwitch(Object input) => switch (input) {
  int _ => _dynamicValue(),
  _ => 1,
};

inferFromArithmetic() => _dynamicValue() + 1;

inferFromCoalesce() => _dynamicValue() ?? 1;

inferFromCascade() => _dynamicValue()..toString();

inferFromUnary() => -_dynamicValue();

inferFromConstructorTearoff() => _boxFactory(1);

inferFromAssignment() => _slot += 1;

inferFromDynamicInvocation() => _dynamicValue().toString();

inferFromDynamicProperty() => _dynamicValue().length;

inferFromPostfixIncrement() => _slot++;

inferFromPrefixIncrement() => ++_slot;

inferFromForInBinding() {
  for (final item in _dynamicIterable) {
    return item;
  }
  return 0;
}

inferFromCStyleForBinding(bool repeat) {
  for (var item = _dynamicValue(); repeat; item = _dynamicValue()) {
    if (item.hashCode > 0) return item;
  }
  return 0;
}

inferFromIfCaseBinding() {
  if (_dynamicValue() case var item) return item;
}

inferFromSwitchStatementBinding() {
  switch (_dynamicValue()) {
    case var item:
      return item;
  }
}

inferFromCollectionIfBinding() => [if (_dynamicValue() case var item) item];

inferFromCollectionForBinding() => [for (final item in _dynamicIterable) item];

inferFromSwitchExpressionBinding() => switch (_dynamicValue()) {
  var item => item,
};

inferFromSwitchRecordBinding() {
  switch (_dynamicRecord) {
    case (var item, _):
      return item;
  }
}

inferFromIfCaseRecordBinding() {
  if (_dynamicRecord case (var item, _)) return item;
  return 0;
}

inferFromMapPatternBinding() {
  switch (_dynamicMap) {
    case {'value': var item}:
      return item;
    default:
      return 0;
  }
}

inferFromListPatternBinding() {
  if (_dynamicList case [var item]) return item;
  return 0;
}

inferFromForInRecordBinding() {
  for (final (item, _) in _dynamicRecords) {
    return item;
  }
  return 0;
}

inferFromSwitchStatementRecordBinding() {
  switch (_dynamicRecord) {
    case (var item, _):
      return item;
  }
}

inferFromCollectionIfRecordBinding() => [
  if (_dynamicRecord case (var item, _)) item,
];

inferFromRecordVariablePattern() {
  var (item, _) = _dynamicRecord;
  return item;
}

inferFromListVariablePattern() {
  final [item] = _dynamicList;
  return item;
}

inferFromMapVariablePattern() {
  var {'value': item} = _dynamicMap;
  return item;
}

inferFromAwaitForBinding() async {
  await for (final item in _dynamicStream) {
    return item;
  }
  return 0;
}

inferFromAwaitForCollectionBinding() async => [
  await for (final item in _dynamicStream) item,
];

inferFromListFirst() => _dynamicListValues.first;

inferFromIterableSingle() => _dynamicIterableValues.single;

inferFromSetLast() => _dynamicSetValues.last;

inferFromMapValues() => _dynamicMapValues.values;

inferFromMapKeys() => _dynamicKeyValues.keys;

inferFromIteratorCurrent() => _dynamicIteratorValues.current;
