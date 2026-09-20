import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for static member rules.
extension ClassHaveStaticMembersPredicateRules on ClassPredicateBuilder {
  /// Selects classes where every field and method is static.
  ClassPredicateBuilder haveOnlyStaticMembers() {
    return satisfy(_classHasOnlyStaticMembers());
  }

  /// Selects classes with at least one non-static field or method.
  ClassPredicateBuilder noHaveOnlyStaticMembers() {
    return satisfy(_classDoesNotHaveOnlyStaticMembers());
  }

  /// Selects classes where every member in [memberNames] is static.
  ClassPredicateBuilder haveAllStaticMembers(Iterable<String> memberNames) {
    final memberList = memberNames.toNonEmptyList('memberNames');
    return satisfy(
      HeimdallPredicate.allOf(
        memberList.map(_classHasStaticMember),
        description: 'have all static members ${memberList.join(', ')}',
      ),
    );
  }

  /// Selects classes where at least one member in [memberNames] is static.
  ClassPredicateBuilder haveAnyStaticMembers(Iterable<String> memberNames) {
    final memberList = memberNames.toNonEmptyList('memberNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        memberList.map(_classHasStaticMember),
        description: 'have any static member ${memberList.join(', ')}',
      ),
    );
  }

  /// Selects classes where none of [memberNames] is static.
  ClassPredicateBuilder haveNoStaticMembers(Iterable<String> memberNames) {
    final memberList = memberNames.toNonEmptyList('memberNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        memberList.map(_classHasStaticMember),
        description: 'have no static members ${memberList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for static member rules.
extension ClassHaveStaticMembersShouldRules on ClassShouldBuilder {
  /// Requires matching classes to declare only static fields and methods.
  HeimdallRule<CompilationUnitMember> haveOnlyStaticMembers() {
    return satisfy(_classShouldHaveOnlyStaticMembers());
  }

  /// Requires matching classes to have at least one non-static field or method.
  HeimdallRule<CompilationUnitMember> noHaveOnlyStaticMembers() {
    return satisfy(_classShouldNotHaveOnlyStaticMembers());
  }

  /// Requires every member in [memberNames] to be static.
  HeimdallRule<CompilationUnitMember> haveAllStaticMembers(
    Iterable<String> memberNames,
  ) {
    final memberList = memberNames.toNonEmptyList('memberNames');
    return satisfy(
      HeimdallCondition.allOf(
        memberList.map(_classShouldHaveStaticMember),
        description: 'have all static members ${memberList.join(', ')}',
      ),
    );
  }

  /// Requires at least one member in [memberNames] to be static.
  HeimdallRule<CompilationUnitMember> haveAnyStaticMembers(
    Iterable<String> memberNames,
  ) {
    final memberList = memberNames.toNonEmptyList('memberNames');
    return satisfy(
      HeimdallCondition.anyOf(
        memberList.map(_classShouldHaveStaticMember),
        description: 'have any static member ${memberList.join(', ')}',
      ),
    );
  }

  /// Requires none of [memberNames] to be static.
  HeimdallRule<CompilationUnitMember> haveNoStaticMembers(
    Iterable<String> memberNames,
  ) {
    final memberList = memberNames.toNonEmptyList('memberNames');
    return satisfy(
      HeimdallCondition.noneOf(
        memberList.map(_classShouldHaveStaticMember),
        description: 'have no static members ${memberList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<CompilationUnitMember> _classShouldHaveOnlyStaticMembers() {
  return HeimdallCondition('have only static members', (item, _) {
    final members = item.members.where(_isStaticEligibleMember).toList();
    final findings = members.isEmpty
        ? [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} declares no fields or methods',
            ),
          ]
        : members
              .where((member) => !member.isStatic)
              .map(
                (member) => HeimdallValidationInfo(
                  filePath: item.sourcePath,
                  line: member.line,
                  message: '${item.name}.${member.name} is not static',
                ),
              )
              .toList();
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotHaveOnlyStaticMembers() {
  return HeimdallCondition('not have only static members', (item, _) {
    final members = item.members.where(_isStaticEligibleMember).toList();
    final findings = members.isEmpty || members.any((member) => !member.isStatic)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} declares only static members',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldHaveStaticMember(
  String memberName,
) {
  return HeimdallCondition('have static member $memberName', (item, _) {
    final findings = _hasStaticMember(item, memberName)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} does not declare static member $memberName',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallPredicate<CompilationUnitMember> _classHasOnlyStaticMembers() {
  return HeimdallPredicate(
    'have only static members',
    (item, _) {
      final members = item.members.where(_isStaticEligibleMember);
      return members.isNotEmpty && members.every((member) => member.isStatic);
    },
  );
}

HeimdallPredicate<CompilationUnitMember> _classDoesNotHaveOnlyStaticMembers() {
  return HeimdallPredicate(
    'not have only static members',
    (item, _) {
      final members = item.members.where(_isStaticEligibleMember);
      return members.isEmpty || members.any((member) => !member.isStatic);
    },
  );
}

HeimdallPredicate<CompilationUnitMember> _classHasStaticMember(
  String memberName,
) {
  return HeimdallPredicate(
    'have static member $memberName',
    (item, _) => _hasStaticMember(item, memberName),
  );
}

bool _hasStaticMember(CompilationUnitMember item, String memberName) {
  return item.members.where(_isStaticEligibleMember).any(
    (member) {
      if (!member.isStatic) return false;
      if (member.isMethod) return member.name == memberName;
      final field = member as FieldDeclaration;
      return field.fields.variables.any(
        (variable) => variable.name.lexeme == memberName,
      );
    },
  );
}

bool _isStaticEligibleMember(ClassMember member) => member.isField || member.isMethod;
