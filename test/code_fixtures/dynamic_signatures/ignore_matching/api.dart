void payload(Map<String, dynamic> value) {}
void nullable(Map<String, dynamic>? value) {}
void nested(Future<Map<String, dynamic>?> value) {}
void differentArgument(Map<String?, dynamic> value) {}
void list(List<dynamic>? value) {}
void direct(dynamic value) {}
void callback(void Function(Map<String, dynamic>, dynamic) value) {}
void record((Map<String, dynamic>, dynamic) value) {}
void boundedCallback(void Function<T extends dynamic>() value) {}
typedef BoundedCallback = void Function<T extends dynamic>();

final explicitList = <dynamic>[];
final emptyList = [];
final explicitMap = <String, dynamic>{};
final emptyMap = {};

class Payload {
  Payload(this.value);
  final Map<String, dynamic>? value;
}
