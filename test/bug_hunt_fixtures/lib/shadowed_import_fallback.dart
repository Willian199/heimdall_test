import 'models.dart' show ShadowedPatternType;

class ShadowedPatternConsumer {
  bool check(Object input) {
    if (input case final Object ShadowedPatternType
        when ShadowedPatternType.toString().isNotEmpty) {
      return true;
    }
    return false;
  }
}

class CollectionGuardConsumer {
  List<bool> check(Object input) => [
    if (input case final Object ShadowedPatternType
        when ShadowedPatternType.toString().isNotEmpty)
      true,
  ];
}

class PatternTypeConsumer {
  bool check(Object input) {
    if (input case final ShadowedPatternType value
        when value.toString().isNotEmpty) {
      return true;
    }
    return false;
  }
}

class ElseTypeConsumer {
  Object check(Object input) {
    if (input case final int ShadowedPatternType when ShadowedPatternType > 0) {
      return ShadowedPatternType;
    } else {
      return ShadowedPatternType();
    }
  }
}

class CollectionElseTypeConsumer {
  List<Object> check(Object input) => [
    if (input case final int ShadowedPatternType when ShadowedPatternType > 0)
      ShadowedPatternType
    else
      ShadowedPatternType(),
  ];
}
