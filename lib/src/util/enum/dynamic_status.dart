/// The result of checking whether a public signature exposes dynamic types.
enum DynamicStatus {
  /// The signature exposes a dynamic type.
  dynamicType,

  /// Analysis established a non-dynamic or exempt type.
  known,

  /// The type could not be established by the available analysis.
  unknown,
}
