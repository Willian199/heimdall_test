/// Helpers for validating iterable arguments used by fluent rule variants.
extension IterableExtension<T> on Iterable<T> {
  /// Converts this iterable to a list and rejects empty values.
  List<T> toNonEmptyList(String name) {
    final list = toList();
    if (list.isEmpty) {
      throw ArgumentError.value(this, name, 'must not be empty');
    }
    return list;
  }

  /// Converts a List to a Immutable List
  List<T> toImmutableList() => List.unmodifiable(this);

  /// Returns the first item or null
  T? get firstOrNull => isEmpty ? null : first;
}
