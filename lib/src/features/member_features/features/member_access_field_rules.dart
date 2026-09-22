import 'package:analyzer/dart/ast/visitor.dart';
import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for executable field access rules.
extension MemberAccessFieldPredicateRules on MemberPredicateBuilder {
  /// Selects executable members that access [fieldName].
  MemberPredicateBuilder accessField(String fieldName) {
    return satisfy(_memberMatchesAccessField(fieldName));
  }

  /// Selects members that do not satisfy `accessField`.
  MemberPredicateBuilder notAccessField(String fieldName) {
    return satisfy(_memberDoesNotAccessField(fieldName));
  }

  /// Selects executable members that access every field in [fieldNames].
  MemberPredicateBuilder accessAllFields(Iterable<String> fieldNames) {
    final fieldList = fieldNames.toNonEmptyList('fieldNames');
    return satisfy(
      HeimdallPredicate.allOf(
        fieldList.map(_memberMatchesAccessField),
        description: 'access all fields ${fieldList.join(', ')}',
      ),
    );
  }

  /// Selects executable members that access at least one field in [fieldNames].
  MemberPredicateBuilder accessAnyField(Iterable<String> fieldNames) {
    final fieldList = fieldNames.toNonEmptyList('fieldNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        fieldList.map(_memberMatchesAccessField),
        description: 'access any field ${fieldList.join(', ')}',
      ),
    );
  }

  /// Selects executable members that access none of [fieldNames].
  MemberPredicateBuilder accessNoFields(Iterable<String> fieldNames) {
    final fieldList = fieldNames.toNonEmptyList('fieldNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        fieldList.map(_memberMatchesAccessField),
        description: 'access no fields ${fieldList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for executable field access rules.
extension MemberAccessFieldShouldRules on MemberShouldBuilder {
  /// Requires executable members to access [fieldName].
  HeimdallRule<ClassMember> accessField(String fieldName) => satisfy(_memberShouldAccessField(fieldName));

  /// Requires members not to satisfy `accessField`.
  HeimdallRule<ClassMember> notAccessField(String fieldName) {
    return satisfy(_memberShouldNotAccessField(fieldName));
  }

  /// Requires executable members to access every field in [fieldNames].
  HeimdallRule<ClassMember> accessAllFields(Iterable<String> fieldNames) {
    final fieldList = fieldNames.toNonEmptyList('fieldNames');
    return satisfy(
      HeimdallCondition.allOf(
        fieldList.map(_memberShouldAccessField),
        description: 'access all fields ${fieldList.join(', ')}',
      ),
    );
  }

  /// Requires executable members to access at least one field in [fieldNames].
  HeimdallRule<ClassMember> accessAnyField(Iterable<String> fieldNames) {
    final fieldList = fieldNames.toNonEmptyList('fieldNames');
    return satisfy(
      HeimdallCondition.anyOf(
        fieldList.map(_memberShouldAccessField),
        description: 'access any field ${fieldList.join(', ')}',
      ),
    );
  }

  /// Requires executable members to access none of [fieldNames].
  HeimdallRule<ClassMember> accessNoFields(Iterable<String> fieldNames) {
    final fieldList = fieldNames.toNonEmptyList('fieldNames');
    return satisfy(
      HeimdallCondition.noneOf(
        fieldList.map(_memberShouldAccessField),
        description: 'access no fields ${fieldList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<ClassMember> _memberShouldAccessField(String fieldName) {
  return HeimdallCondition('access field $fieldName', (item, _) {
    final findings = _memberAccessesField(item, fieldName)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.ownerName}.${item.name} does not access field $fieldName',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<ClassMember> _memberShouldNotAccessField(String fieldName) {
  return prohibitedMemberCondition(
    'access field $fieldName',
    (item, project) => _memberAccessesField(item, fieldName),
  );
}

HeimdallPredicate<ClassMember> _memberMatchesAccessField(String fieldName) {
  return HeimdallPredicate(
    'access field $fieldName',
    (item, project) => _memberAccessesField(item, fieldName),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotAccessField(String fieldName) {
  return HeimdallPredicate(
    'not access field $fieldName',
    (item, project) => !_memberAccessesField(item, fieldName),
  );
}

bool _memberAccessesField(ClassMember member, String fieldName) {
  final visitor = _FieldAccessVisitor(
    fieldName,
    member.parameters.map((parameter) => parameter.name?.lexeme).whereType<String>().toSet(),
  );
  for (final root in member.executableRoots) {
    root.accept(visitor);
    if (visitor.found) return true;
  }
  return false;
}

final class _FieldAccessVisitor extends RecursiveAstVisitor<void> {
  _FieldAccessVisitor(this.fieldName, Set<String> localNames) : _scopes = [localNames];

  final String fieldName;
  final List<Set<String>> _scopes;
  bool found = false;

  bool get _isLocalName => _scopes.any((scope) => scope.contains(fieldName));

  void _declare(String name) {
    _scopes.last.add(name);
  }

  void _withScope(void Function() visit, {Iterable<String> names = const []}) {
    _scopes.add(names.toSet());
    visit();
    _scopes.removeLast();
  }

  @override
  void visitBlock(Block node) {
    if (found) return;
    _withScope(() => super.visitBlock(node));
  }

  @override
  void visitForEachPartsWithDeclaration(ForEachPartsWithDeclaration node) {
    if (found) return;
    _declare(node.loopVariable.name.lexeme);
    node.iterable.accept(this);
  }

  @override
  void visitForPartsWithDeclarations(ForPartsWithDeclarations node) {
    if (found) return;
    node.variables.accept(this);
    node.condition?.accept(this);
    for (final updater in node.updaters) {
      updater.accept(this);
    }
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    if (found) return;
    _declare(node.name.lexeme);
    final parameterNames =
        node.functionExpression.parameters?.parameters.map((parameter) => parameter.name?.lexeme).whereType<String>() ?? const <String>[];
    _withScope(
      () => node.functionExpression.body.accept(this),
      names: parameterNames,
    );
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    if (found) return;
    final parameterNames = node.parameters?.parameters.map((parameter) => parameter.name?.lexeme).whereType<String>() ?? const <String>[];
    _withScope(() => node.body.accept(this), names: parameterNames);
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (found) return;
    if (node.identifier.name == fieldName) {
      found = true;
      return;
    }
    super.visitPrefixedIdentifier(node);
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    if (found) return;
    if (node.propertyName.name == fieldName) {
      found = true;
      return;
    }
    super.visitPropertyAccess(node);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (found) return;
    if (node.name == fieldName && !_isLocalName) {
      found = true;
      return;
    }
    super.visitSimpleIdentifier(node);
  }

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    if (found) return;
    node.initializer?.accept(this);
    _declare(node.name.lexeme);
  }
}
