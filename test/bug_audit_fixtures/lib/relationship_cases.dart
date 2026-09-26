class ConditionalListField {
  final Object value = Object();

  List<Object> props(bool include) => [if (include) value];
}

class LoopListField {
  final Object value = Object();

  List<Object> props(Iterable<bool> flags) => [for (final flag in flags) value];
}

class BranchListFields {
  final Object first = Object();
  final Object second = Object();

  List<Object> props(bool chooseFirst) => [if (chooseFirst) first else second];
}

class ConditionalListShapes {
  final Object nestedIf = Object();
  final Object conditionalBranch = Object();
  final Object conditionalAlways = Object();
  final Object loopOnly = Object();
  final Object loopAlways = Object();
  final Object loopConditional = Object();

  List<Object> nested(bool outer, bool inner) => [
    if (outer)
      if (inner) nestedIf,
  ];

  List<Object> branchAndAlways(bool include) => [if (include) conditionalBranch, conditionalAlways];

  List<Object> loopAndAlways(Iterable<bool> flags) => [for (final flag in flags) loopOnly, loopAlways];

  List<Object> loopAndConditional(Iterable<bool> flags) => [
    for (final flag in flags)
      if (flag) loopConditional,
  ];
}

class GuardShadowField {
  final int value = 1;

  bool readPatternGuard(Object input) {
    if (input case final int value when value > 0) {
      return true;
    }
    return false;
  }

  bool readPatternGuardInElement(Object input) => [
    if (input case final int value when value > 0) value > 0,
  ].isNotEmpty;
}
