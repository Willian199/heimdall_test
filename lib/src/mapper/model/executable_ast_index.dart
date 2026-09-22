import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// Internal expression index.
final class ExecutableAstIndex {
  /// Collects expressions from the given roots.
  ExecutableAstIndex(Iterable<AstNode> roots) {
    final visitor = _ExpressionVisitor();
    for (final root in roots) {
      root.accept(visitor);
    }
    expressions = List.unmodifiable(visitor.expressions);
  }

  /// Expressions in source traversal order, including nested closures.
  late final List<Expression> expressions;
}

final class _ExpressionVisitor extends GeneralizingAstVisitor<void> {
  final expressions = <Expression>[];

  @override
  void visitExpression(Expression node) {
    expressions.add(node);
    super.visitExpression(node);
  }
}
