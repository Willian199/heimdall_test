// Legal Dart, intentionally testing a return overridden by finally.
// ignore_for_file: control_flow_in_finally

class FinallyOverridesReturn {
  final int value = 1;

  List<Object> props() {
    try {
      return const [];
    } finally {
      return [value];
    }
  }
}
