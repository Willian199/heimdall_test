String guardedByReturn(String? value) {
  if (value == null) return 'fallback';
  return value!;
}

String guardedByBranch(String? value) {
  if (value != null) return value!;
  return 'fallback';
}

bool guardedByShortCircuit(String? value) {
  return value != null && value!.isNotEmpty;
}

String guardedByConditional(String? value) {
  return value != null ? value! : 'fallback';
}

String guardedByAssignment(String? value) {
  value = 'fallback';
  return value!;
}

String guardedByFallbackAssignment(String? value) {
  value ??= 'fallback';
  return value!;
}

String unsafeDirectly(String? value) => value!;

String unsafeAfterWrite(String? value) {
  if (value == null) return 'fallback';
  value = null;
  return value!;
}

bool unsafeWithinShortCircuit(String? value) {
  return value != null && (value = null) == null && value!.isEmpty;
}

String unsafeAfterClosureCall(String? value) {
  void clear() => value = null;

  if (value == null) return 'fallback';
  clear();
  return value!;
}

final class Holder {
  String? value;

  String unsafeProperty() => value!;
}
