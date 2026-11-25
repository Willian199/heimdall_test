import 'package:analyzer/dart/element/element.dart';
import 'package:heimdall_test/src/core.dart';
import 'package:heimdall_test/src/mapper/model/declaration_namespace_index.dart';
import 'package:heimdall_test/src/util/enum/declaration_symbol_kind.dart';
import 'package:heimdall_test/src/util/extension/scope/ast_node_extension.dart';
import 'package:heimdall_test/src/util/extension/simple_identifier_extension.dart';

/// Collects value references once, indexed by import prefix and symbol name.
///
/// Resolved elements take precedence over syntax. Syntax is used for unresolved
/// occurrences and for the alternative branches of conditional imports.
final class ValueReferenceIndex {
  /// Indexes the expressions in [item], respecting lexical and member scopes.
  ValueReferenceIndex(CompilationUnitMember item, this._project) {
    final file = _project.filesByPath[item.sourcePath];
    for (final expression in file?.expressionsInDeclaration(item) ?? const <Expression>[]) {
      // These syntax nodes can contain identifiers but do not read values.
      if (expression.thisOrAncestorOfType<NamedType>() != null || expression.thisOrAncestorOfType<ConstructorName>() != null) {
        continue;
      }
      switch (expression) {
        case MethodInvocation(:final target, :final methodName, :final isCascaded):
          if (!isCascaded) {
            if (target == null) {
              _record(methodName);
            } else if (target is SimpleIdentifier) {
              _record(methodName, prefix: target);
            }
          }
        case PrefixedIdentifier(:final prefix, :final identifier):
          _record(identifier, prefix: prefix);
        case SimpleIdentifier():
          final parent = expression.parent;
          final isSelector =
              parent is PropertyAccess && identical(parent.propertyName, expression) ||
              parent is PrefixedIdentifier && identical(parent.identifier, expression);
          if (!isSelector && expression.isValueReference) {
            _record(expression);
          }
      }
    }
  }

  final HeimdallProject _project;
  final _references = <(String?, String), List<SimpleIdentifier>>{};

  /// Whether a visible symbol is read, written, invoked, or torn off.
  bool references(DeclarationSymbol symbol, Directive directive) {
    final prefix = directive is ImportDirective ? directive.prefix?.name : null;
    return (_references[(prefix, symbol.name)] ?? const []).any((reference) {
      if (symbol.kind == DeclarationSymbolKind.getter && !reference.inGetterContext() ||
          symbol.kind == DeclarationSymbolKind.setter && !reference.inSetterContext()) {
        return false;
      }
      final element = reference.element;
      if (element != null && symbol.element != null && directive.targetUris.length == 1) {
        return element == symbol.element ||
            symbol.kind == DeclarationSymbolKind.variable && element is PropertyAccessorElement && element.variable == symbol.element;
      }
      return true;
    });
  }

  void _record(SimpleIdentifier reference, {SimpleIdentifier? prefix}) {
    final binding = prefix ?? reference;
    if (reference.element == null && binding.hasValueReceiver(binding.name, _project)) {
      return;
    }
    (_references[(prefix?.name, reference.name)] ??= []).add(reference);
  }
}
