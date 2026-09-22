import 'dart:core' as core;

Map<String, dynamic> payload() => throw 0;
List<Map<String, dynamic>> payloads() => throw 0;
Map<String, dynamic>? nullablePayload() => throw 0;
Map<dynamic, String> dynamicKey() => throw 0;
Map<String, List<dynamic>> nestedDynamic() => throw 0;
core.Map<String, dynamic> prefixed() => throw 0;
void mixed(Map<String, dynamic> payload, dynamic other) {}
typedef Json = Map<String, dynamic>;
Json alias() => throw 0;
final inferred = <String, dynamic>{};
typedef Callback = dynamic Function(int);
Callback callback() => throw 0;
