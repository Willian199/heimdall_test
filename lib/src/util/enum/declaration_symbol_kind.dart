/// The namespace category of an individual top-level symbol.
enum DeclarationSymbolKind {
  /// A type or type alias.
  type,

  /// A top-level function.
  function,

  /// A top-level getter.
  getter,

  /// A top-level setter.
  setter,

  /// One variable, independently of others in the same declaration.
  variable,
}
