/// Kinds of class members that can be selected by member rules.
enum MemberKind {
  /// A method declaration.
  method,

  /// Any constructor declaration.
  constructor,

  /// A factory constructor declaration.
  factoryConstructor,

  /// A generative constructor declaration.
  generativeConstructor,
}
