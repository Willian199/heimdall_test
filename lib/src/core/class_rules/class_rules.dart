import 'package:heimdall_test/heimdall_test.dart';

/// DSL entry point for class and type declaration rules.
///
/// This rule family evaluates `HeimdallProject.typeDeclarations`, which
/// includes classes, enums, mixins, extensions, and extension types.
final class ClassRules implements HeimdallRules<ClassPredicateBuilder, ClassShouldBuilder> {
  /// Creates a class rule entry point.
  const ClassRules({required this.inverted});

  /// Whether generated rules should invert their final condition.
  final bool inverted;

  /// Starts selecting type declarations with predicates.
  @override
  ClassPredicateBuilder that() => ClassPredicateBuilder(inverted: inverted);

  /// Starts asserting conditions over all type declarations.
  @override
  ClassShouldBuilder should() => ClassPredicateBuilder(inverted: inverted).should();
}
