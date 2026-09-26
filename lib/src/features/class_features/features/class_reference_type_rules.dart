import 'package:analyzer/dart/ast/visitor.dart';
import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/class_features/helpers/declaration_condition.dart';

/// Predicate-side DSL for raw type reference rules.
extension ClassReferenceTypePredicateRules on ClassPredicateBuilder {
  /// Selects classes that reference a type named [typeName].
  ClassPredicateBuilder referenceType(String typeName) {
    return satisfy(
      HeimdallPredicate(
        'reference type $typeName',
        (item, _) => _referencesType(item, typeName),
      ),
    );
  }

  /// Selects classes that do not reference a type named [typeName].
  ClassPredicateBuilder notReferenceType(String typeName) {
    return satisfy(
      HeimdallPredicate(
        'not reference type $typeName',
        (item, _) => !_referencesType(item, typeName),
      ),
    );
  }
}

/// Condition-side DSL for raw type reference rules.
extension ClassReferenceTypeShouldRules on ClassShouldBuilder {
  /// Requires classes to reference a type named [typeName].
  HeimdallRule<CompilationUnitMember> referenceType(String typeName) {
    return satisfy(
      declarationCondition(
        'reference type $typeName',
        (item) => _referencesType(item, typeName),
      ),
    );
  }

  /// Requires classes not to reference a type named [typeName].
  HeimdallRule<CompilationUnitMember> notReferenceType(String typeName) {
    return satisfy(
      declarationCondition(
        'not reference type $typeName',
        (item) => !_referencesType(item, typeName),
      ),
    );
  }
}

bool _referencesType(CompilationUnitMember item, String typeName) {
  final finder = _NamedTypeFinder(typeName);
  item.accept(finder);
  return finder.found;
}

final class _NamedTypeFinder extends RecursiveAstVisitor<void> {
  _NamedTypeFinder(this.target);

  final String target;
  bool found = false;

  @override
  void visitNamedType(NamedType node) {
    if (node.name.lexeme == target) {
      found = true;
    }
    super.visitNamedType(node);
  }
}
