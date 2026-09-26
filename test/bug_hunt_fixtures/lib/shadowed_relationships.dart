class IfElementShadow {
  final int value = 0;

  Object get input => 1;

  List<int> get props => [if (input case final int value) value];
}

class SwitchExpressionShadow {
  final int value;

  SwitchExpressionShadow({required this.value, required Object input});

  SwitchExpressionShadow copy(int value, Object input) => switch (input) {
    int value => SwitchExpressionShadow(value: value, input: input),
    _ => SwitchExpressionShadow(value: value, input: input),
  };
}

class IfElementElseField {
  final int value = 0;
  Object get input => 'other';

  List<int> get props => [if (input case final int value) value else value];
}

class IfElementExplicitField {
  final int value = 0;
  Object get input => 1;

  List<int> get props => [
    if (input case final int value when value > 0) this.value,
  ];
}

class SwitchExpressionListShadow {
  final int value = 0;
  Object get input => 1;

  List<int> get props => switch (input) {
    final int value => [value],
    _ => [],
  };
}

class SwitchExpressionForwardedParameter {
  SwitchExpressionForwardedParameter({required this.value});

  final int value;

  SwitchExpressionForwardedParameter copy(int value, Object input) =>
      switch (input) {
        final int other when other > 0 => SwitchExpressionForwardedParameter(
          value: value,
        ),
        _ => SwitchExpressionForwardedParameter(value: value),
      };
}
