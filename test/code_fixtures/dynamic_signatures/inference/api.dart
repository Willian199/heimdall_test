import 'dart:async';

dynamic _value = 1;
dynamic _source() => 1;
int _safeSource() => 1;
_forward() => _source();
_cycleA() => _cycleB();
_cycleB() => _cycleA();
T _identity<T>(T value) => value;

result() => _source();
forwarded() => _forward();
final called = _source();
final list = [_value];
final map = {'value': _value};
final set = {_value};
final spread = [...list];
final conditionalList = [if (true) _value else 1];
final loopList = [for (var i = 0; i < 1; i++) _value];
final indexed = <dynamic>[1][0];
final indexedVariable = list[0];
final indexedMap = <String, dynamic>{'value': 1}['value'];
final inferredMapIndex = map['value'];
final future = Future.value(_value);
final stream = Stream.value(_value);
final constructed = _Box(_value);
final explicitConstructor = _Box<dynamic>(1);
final genericCall = _identity(_value);
final explicitGenericCall = _identity<dynamic>(1);

final _model = _Model();
final property = _model.value;
final getter = _model.item;
final method = _model.read();
final staticMethod = _Model.load();
final genericProperty = _Box<dynamic>(1).value;
final inheritedProperty = _Child().value;
final callback = (() => _value)();
final _callback = () => _value;
final callbackVariable = _callback();
final _typedCallback = _source;
final tearOff = _source;

awaited() async => await Future<dynamic>.value(1);
generated() sync* { yield _value; }
generatedAsync() async* { yield _source(); }
delegated() sync* { yield* <dynamic>[1]; }
localCall() {
  dynamic source() => 1;
  return source();
}

final safeCall = _safeSource();
final safeList = [1, 2];
final safeExplicitList = <Object>[_value];
final safeMapIndex = <dynamic, int>{'value': 1}['value'];
final safeInferredMapIndex = {_value: 1}['value'];
final safeFuture = Future.value(1);
final safeExplicitFuture = Future<Object>.value(_value);
final safeConstructor = _Box(1);
final safeNonGeneric = _NonGeneric(_value);
final safeGenericCall = _identity(1);
final safeProperty = _model.count;
final safeMethod = _model.safeRead();
final safeGenericProperty = _Box<int>(1).value;
final safeAnnotatedGeneric = _identity<Object>(_value);
final safeCallback = ((dynamic value) => 1)(_value);
safeAwaited() async => await Future<int>.value(1);
safeGenerated() sync* { yield 1; }
safeCycle() => _cycleA();
safeShadowing() {
  int _source() => 1;
  return _source();
}

class _Model {
  dynamic value = 1;
  int count = 1;
  dynamic get item => value;
  dynamic read() => value;
  int safeRead() => count;
  static dynamic load() => 1;
}
class _Box<T> {
  _Box(this.value);
  final T value;
}
class _Child extends _Box<dynamic> {
  _Child() : super(1);
}
class _NonGeneric {
  _NonGeneric(dynamic value);
}

class GenericMethod {
  T _identity<T>(T value) => value;

  get resultFromMethod => _identity<dynamic>(1);
  get inferredFromMethod => _identity(_value);
  get resultFromReceiver => this._identity<dynamic>(1);
  get safeFromMethod => _identity<int>(1);
}
