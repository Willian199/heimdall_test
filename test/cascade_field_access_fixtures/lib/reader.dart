// Intentionally exercise a cascade assignment.
// ignore_for_file: avoid_single_cascade_in_expression_statements

class Reader {
  int value = 0;

  void writeThroughCascade() {
    this..value = 3;
  }
}
