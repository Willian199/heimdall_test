import 'package:heimdall_test/src/core.dart';

/// Dependency edge retaining the original directive and target declaration.
final class DeclarationDependency {
  /// Creates a declaration dependency edge.
  const DeclarationDependency({required this.directive, required this.target, required this.targetUri});

  /// Directive that introduced the dependency.
  final Directive directive;

  /// Referenced target declaration.
  final CompilationUnitMember target;

  /// Conditional URI branch that exposed the target.
  final String targetUri;
}

/// Immutable dependency results owned by one imported project snapshot.
final class DeclarationDependencyIndex {
  final _types = <CompilationUnitMember, List<DeclarationDependency>>{};
  final _all = <CompilationUnitMember, List<DeclarationDependency>>{};

  /// Collects type edges on first use and reuses them across later rules.
  List<DeclarationDependency> typesFor(CompilationUnitMember item, List<DeclarationDependency> Function() collect) =>
      _types.putIfAbsent(item, () => List.unmodifiable(collect()));

  /// Collects type and value edges once, without mixing type-only results.
  List<DeclarationDependency> allFor(CompilationUnitMember item, List<DeclarationDependency> Function() collect) =>
      _all.putIfAbsent(item, () => List.unmodifiable(collect()));
}
