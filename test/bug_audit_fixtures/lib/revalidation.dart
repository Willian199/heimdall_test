import 'hierarchy_cases.dart' as other;

final List<List<dynamic>> _nested = [];
final _inferred = <dynamic>[];
final List<int> _ints = [];
final List<dynamic> _dynamic = [];

final nestedLength = () => _nested.first.length;
final inferredLength = () => _inferred.length;
final mappedLength = () => _ints.map((value) => <dynamic>[]).first.length;
final callbackLength = () => _nested.map((value) => value.length);
final explicitDynamicParameter = () => _ints.map((dynamic value) => value);
final typedCallback = () => _dynamic.map((Object? value) => value);
dynamic _dynamicIdentity(int value) => value;
final tearOffCallback = () => _ints.map(_dynamicIdentity);
final nestedCastLength = () => _dynamic.cast<List<dynamic>>().first.length;
final rawMappedLength = () => _dynamic.map((value) => value).length;

class ConstructorCounterexamples {
  void Product() {}

  void prefixedConstruction() {
    other.Product();
  }

  void localFunctionCall() {
    void ProducedValue() {}
    ProducedValue();
  }
}
