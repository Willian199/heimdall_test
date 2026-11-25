import 'package:analyzer/dart/ast/ast.dart';

/// Shared queries for [Expression] nodes.
extension ExpressionExtension on Expression? {
  /// Whether this expression is a postfix null assertion.
  bool get isNullAssertion => switch (this) {
    PostfixExpression(:final operator) => operator.lexeme == '!',
    _ => false,
  };

  /// A dotted identifier name, or `null` for a computed expression.
  String? get qualifiedName => switch (this) {
    SimpleIdentifier(:final name) => name,
    PrefixedIdentifier(:final prefix, :final identifier) => '${prefix.name}.${identifier.name}',
    PropertyAccess(:final target, :final propertyName) => switch (target.qualifiedName) {
      final targetName? => '$targetName.${propertyName.name}',
      null => null,
    },
    ParenthesizedExpression(:final expression) => expression.qualifiedName,
    _ => null,
  };
}
