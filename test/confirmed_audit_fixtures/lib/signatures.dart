dynamic _dynamicValue = 1;
final assignmentResult = (_dynamicValue = 1);
final integerSum = 1 + _dynamicValue;
final integerComparison = 1 < _dynamicValue;
final integerDivision = 1 / _dynamicValue;
final integerShift = 1 << _dynamicValue;
final booleanXor = true ^ _dynamicValue;

class _Operators {
  dynamic operator -() => 1;
  dynamic operator ~() => 1;
  dynamic operator +(_Operators other) => 1;
}

final unaryMinus = -_Operators();
final unaryComplement = ~_Operators();
final binaryOverload = _Operators() + _Operators();

class _Methods {
  int take(dynamic value) => 1;
  static int staticTake(dynamic value) => 1;
  final dynamic Function() callback = () => 1;
}

final instanceTearoff = _Methods().take;
final staticTearoff = _Methods.staticTake;
final callbackFieldResult = _Methods().callback();

final (int, dynamic) _mixedRecord = (1, 2);
final ({int safe, dynamic unsafe}) _namedRecord = (safe: 1, unsafe: 2);
final recordPosition = _mixedRecord.$2;
final recordName = _namedRecord.unsafe;
final destructuredRecord = () {
  final (safe, unsafe) = _mixedRecord;
  return safe;
};
final destructuredNamed = () {
  final (:safe, :unsafe) = _namedRecord;
  return safe;
};
final typedForLoop = () {
  for (final int value in <dynamic>[1]) {
    return value;
  }
  return 0;
};
final typedPattern = () {
  final (int safe, _) = _mixedRecord;
  return safe;
};
final dynamicPattern = () {
  final (dynamic value,) = (1,);
  return value;
};

final nullAwareList = [?_dynamicValue];
final nullAwareSet = {?_dynamicValue};

class _Box<T> {
  _Box.named();
}

final rawNamedConstructor = _Box.named();
typedef _Alias<T> = _Box<T>;
final rawAliasConstructor = _Alias.named();

typedef _DynamicFunction = dynamic Function();
late _DynamicFunction _functionAlias;
final functionAliasResult = _functionAlias();

class _Callable {
  dynamic call() => 1;
}

final _callable = _Callable();
final callableResult = _callable();

final implicitCatch = () {
  try {
    throw 1;
  } catch (error) {
    return error;
  }
};

class _GetterParent {
  int get value => 1;
  set value(dynamic input) {}
}

class SetterOverride extends _GetterParent {
  @override
  set value(input) {}
}
