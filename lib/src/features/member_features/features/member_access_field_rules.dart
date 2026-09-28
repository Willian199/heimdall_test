import 'package:analyzer/dart/ast/visitor.dart';
import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_lookup_queries.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';
import 'package:heimdall_test/src/features/queries/value_reference_queries.dart';

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
  return HeimdallCondition('access field $fieldName', (item, project) {
    final findings = _memberAccessesField(item, fieldName, project)
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
    (item, project) => _memberAccessesField(item, fieldName, project),
  );
}

HeimdallPredicate<ClassMember> _memberMatchesAccessField(String fieldName) {
  return HeimdallPredicate(
    'access field $fieldName',
    (item, project) => _memberAccessesField(item, fieldName, project),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotAccessField(String fieldName) {
  return HeimdallPredicate(
    'not access field $fieldName',
    (item, project) => !_memberAccessesField(item, fieldName, project),
  );
}

bool _memberAccessesField(ClassMember member, String fieldName, HeimdallProject project) {
  final visited = <CompilationUnitMember>{};
  bool declares(CompilationUnitMember owner) {
    if (!visited.add(owner)) {
      return false;
    }

    if (owner.fieldVariables.any((variable) => variable.name.lexeme == fieldName) ||
        owner.methods.any((method) => (method.isGetter || method.isSetter) && method.name.lexeme == fieldName)) {
      return true;
    }

    final parents = switch (owner) {
      ClassDeclaration() => [if (owner.extendsClause != null) owner.extendsClause!.superclass, ...?owner.withClause?.mixinTypes],
      EnumDeclaration() => [...?owner.withClause?.mixinTypes],
      MixinDeclaration() => [...?owner.onClause?.superclassConstraints],
      ClassTypeAlias() => [owner.superclass, ...owner.withClause.mixinTypes],
      _ => <NamedType>[],
    };

    return parents.any((parent) {
      final declaration = declarationNamedFrom(owner, project, parent.toSource());
      return declaration != null && declares(declaration);
    });
  }

  if (!declares(member.owner)) {
    return false;
  }
  final visitor = _FieldAccessVisitor(fieldName);
  for (final root in member.executableRoots) {
    root.accept(visitor);
    if (visitor.found) {
      return true;
    }
  }
  return false;
}

final class _FieldAccessVisitor extends RecursiveAstVisitor<void> {
  _FieldAccessVisitor(this.fieldName);

  final String fieldName;
  bool found = false;

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (found) {
      return;
    }
    if (node.name != fieldName || !isValueReference(node)) {
      return;
    }
    final parent = node.parent;
    if (parent is PrefixedIdentifier && identical(parent.identifier, node)) {
      return;
    }
    if (parent is PropertyAccess && identical(parent.propertyName, node)) {
      if (parent.realTarget is ThisExpression || parent.realTarget is SuperExpression) {
        found = true;
      }
      return;
    }
    if (parent is MethodInvocation && identical(parent.methodName, node)) {
      return;
    }
    if (!isShadowedValue(node)) {
      found = true;
    }
  }
}
