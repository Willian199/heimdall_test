import 'package:analyzer/dart/ast/ast.dart';

/// Shared queries for [Statement] nodes.
extension StatementExtension on Statement {
  /// Whether this statement always returns or throws in the supported syntax.
  bool get alwaysExits => switch (this) {
    ReturnStatement() => true,
    ExpressionStatement(:final expression) => expression is ThrowExpression || expression is RethrowExpression,
    Block(:final statements) => statements.any((statement) => statement.alwaysExits),
    IfStatement(:final thenStatement, :final elseStatement) => elseStatement != null && thenStatement.alwaysExits && elseStatement.alwaysExits,
    _ => false,
  };
}
