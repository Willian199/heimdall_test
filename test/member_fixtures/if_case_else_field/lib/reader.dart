class IfCaseElseReader {
  int value = 1;
  Object? input;

  List<Object> get props {
    if (input case int value) {
      return [value];
    } else {
      return [value];
    }
  }
}
