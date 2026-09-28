mixin HasSharedState {
  // Dart prohibits instance fields in mixins applied to enums.
  int get shared => 0;
}

enum Status with HasSharedState {
  active;

  int readShared() => shared;
}
