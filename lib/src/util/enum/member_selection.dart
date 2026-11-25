/// Member groups supported by member rules.
enum MemberSelection {
  /// Selects every class member.
  members,

  /// Selects field declarations.
  fields,

  /// Selects method declarations.
  methods,

  /// Selects constructor declarations.
  constructors,

  /// Selects executable class members, meaning methods and constructors.
  codeUnits,
}
