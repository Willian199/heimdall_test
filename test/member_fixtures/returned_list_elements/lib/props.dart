class CollectionIfProps {
  final int value = 1;
  final bool include = true;

  List<Object> get props => [if (include) value];
}

class CollectionIfElseProps {
  final int value = 1;
  final bool include = true;

  List<Object> get props => [if (include) value else value];
}

class CollectionForProps {
  final int value = 1;
  final List<int> indexes = const [1, 2];

  List<Object> get props => [for (final index in indexes) if (index > 0) value];
}

class SwitchExpressionProps {
  final int value = 1;

  List<Object> get props => switch (value) {
    1 => [value],
    _ => [value],
  };
}
