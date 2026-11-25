/// The direction in which a layer dependency constraint is enforced.
enum LayerConstraintDirection {
  /// Restricts which layers a layer may access.
  access,

  /// Restricts which layers may access a layer.
  beAccessedBy,
}
