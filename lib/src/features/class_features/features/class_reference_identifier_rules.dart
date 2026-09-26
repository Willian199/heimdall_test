import 'package:analyzer/dart/ast/visitor.dart';
import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/class_features/helpers/declaration_condition.dart';

/// Predicate-side DSL for raw identifier reference rules.
extension ClassReferenceIdentifierPredicateRules on ClassPredicateBuilder {
  /// Selects classes that reference an identifier named [identifierName].
  ClassPredicateBuilder referenceIdentifier(String identifierName) {
    return satisfy(
      HeimdallPredicate(
        'reference identifier $identifierName',
        (item, _) => _referencesIdentifier(item, identifierName),
      ),
    );
  }

  /// Selects classes that do not reference an identifier named [identifierName].
  ClassPredicateBuilder notReferenceIdentifier(String identifierName) {
    return satisfy(
      HeimdallPredicate(
        'not reference identifier $identifierName',
        (item, _) => !_referencesIdentifier(item, identifierName),
      ),
    );
  }
}

/// Condition-side DSL for raw identifier reference rules.
extension ClassReferenceIdentifierShouldRules on ClassShouldBuilder {
  /// Requires classes to reference an identifier named [identifierName].
  HeimdallRule<CompilationUnitMember> referenceIdentifier(
    String identifierName,
  ) {
    return satisfy(
      declarationCondition(
        'reference identifier $identifierName',
        (item) => _referencesIdentifier(item, identifierName),
      ),
    );
  }

  /// Requires classes not to reference an identifier named [identifierName].
  HeimdallRule<CompilationUnitMember> notReferenceIdentifier(
    String identifierName,
  ) {
    return satisfy(
      declarationCondition(
        'not reference identifier $identifierName',
        (item) => !_referencesIdentifier(item, identifierName),
      ),
    );
  }
}

bool _referencesIdentifier(CompilationUnitMember item, String identifierName) {
  final finder = _IdentifierFinder(identifierName);
  item.accept(finder);
  return finder.found;
}

final class _IdentifierFinder extends RecursiveAstVisitor<void> {
  _IdentifierFinder(this.target);

  final String target;
  bool found = false;

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (!node.inDeclarationContext() && node.name == target) {
      found = true;
    }
    super.visitSimpleIdentifier(node);
  }

  @override
  void visitNamedType(NamedType node) {
    if (node.name.lexeme == target) {
      found = true;
    }
    super.visitNamedType(node);
  }
}
