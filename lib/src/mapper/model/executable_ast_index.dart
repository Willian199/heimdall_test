import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// Internal expression index.
final class ExecutableAstIndex {
  /// Collects expressions from the given roots.
  ExecutableAstIndex(Iterable<AstNode> roots) {
    final visitor = _ExpressionVisitor();
    for (final root in roots) {
      final start = visitor.expressions.length;
      root.accept(visitor);
      _ranges[root] = (start, visitor.expressions.length);
    }
    expressions = List.unmodifiable(visitor.expressions);
  }

  /// Expressions in source traversal order, including nested closures.
  late final List<Expression> expressions;

  final _ranges = <AstNode, (int, int)>{};
  final _scopedExpressions = <AstNode, List<Expression>>{};

  /// Reuses the expression slice collected for an original root.
  List<Expression> expressionsFor(AstNode root) {
    final range = _ranges[root];
    if (range == null) {
      return const [];
    }
    return _scopedExpressions.putIfAbsent(root, () => List.unmodifiable(expressions.getRange(range.$1, range.$2)));
  }
}

final class _ExpressionVisitor extends GeneralizingAstVisitor<void> {
  final expressions = <Expression>[];

  @override
  void visitExpression(Expression node) {
    expressions.add(node);
    super.visitExpression(node);
  }
}
