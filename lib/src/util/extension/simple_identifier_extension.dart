import 'package:heimdall_test/src/core.dart';
import 'package:heimdall_test/src/util/extension/scope/ast_node_extension.dart';

/// Shared queries for [SimpleIdentifier] nodes.
extension SimpleIdentifierExtension on SimpleIdentifier {
  /// Whether this node is a value read or write, rather than a declaration or label.
  bool get isValueReference {
    final parent = this.parent;
    if (parent is VariableDeclaration && identical(parent.name, this) ||
        parent is DeclaredIdentifier && identical(parent.name, this) ||
        parent is DeclaredVariablePattern && identical(parent.name, this) ||
        parent is MethodInvocation && identical(parent.methodName, this) ||
        parent is Label ||
        parent is FormalParameter ||
        parent is MethodDeclaration ||
        parent is FunctionDeclaration) {
      return false;
    }
    return true;
  }

  /// Whether a lexical binding hides a value with the same name at this node.
  bool get isShadowedValue => isShadowedValueName(name);
}
