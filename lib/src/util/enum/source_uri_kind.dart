/// The schemes recognized by source dependency rules.
enum SourceUriKind {
  /// A Dart SDK library.
  dart,

  /// A package library.
  package,

  /// A URI without a scheme.
  relative,

  /// An unrecognized or malformed URI.
  other,
}
