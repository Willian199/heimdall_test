class CopyState {
  final int count;

  CopyState({required this.count});

  CopyState copy(int count, Object? candidate) {
    if (candidate case int count) {
      throw StateError('pattern matched: $count');
    } else {
      return CopyState(count: count);
    }
  }

  CopyState copyFromSwitch(int? count, bool replace) => switch (replace) {
    true => CopyState(count: count ?? this.count),
    false => CopyState(count: count ?? this.count),
  };
}
