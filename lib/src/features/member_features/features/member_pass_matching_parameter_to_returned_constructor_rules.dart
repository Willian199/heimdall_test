import 'package:heimdall_test/heimdall_test.dart';

/// Selects fields forwarded through their matching method parameter to a
/// named argument of a returned constructor of the same class.
extension MemberForwardParameterPredicateRules on MemberPredicateBuilder {
  /// Selects fields forwarded in every return of [methodName].
  MemberPredicateBuilder passMatchingParameterToReturnedConstructorIn(String methodName) => satisfy(
    HeimdallPredicate(
      'pass matching parameter to returned constructor in $methodName',
      (item, _) => item is FieldDeclaration && _missingFields(item, methodName).isEmpty,
    ),
  );

  /// Selects fields not forwarded in every return of [methodName].
  MemberPredicateBuilder notPassMatchingParameterToReturnedConstructorIn(String methodName) => satisfy(
    HeimdallPredicate(
      'not pass matching parameter to returned constructor in $methodName',
      (item, _) => item is FieldDeclaration && _missingFields(item, methodName).isNotEmpty,
    ),
  );
}

/// Checks field forwarding in a method such as `copyWith`.
extension MemberForwardParameterShouldRules on MemberShouldBuilder {
  /// Requires every field to be forwarded in every return of [methodName].
  HeimdallRule<ClassMember> passMatchingParameterToReturnedConstructorIn(String methodName) => satisfy(_condition(methodName));

  /// Requires at least one field not to be forwarded in [methodName].
  HeimdallRule<ClassMember> notPassMatchingParameterToReturnedConstructorIn(String methodName) => satisfy(_condition(methodName, prohibited: true));
}

HeimdallCondition<ClassMember> _condition(String methodName, {bool prohibited = false}) {
  final description = '${prohibited ? 'not ' : ''}pass matching parameter to returned constructor in $methodName';
  return HeimdallCondition(description, (member, _) {
    if (member is! FieldDeclaration) {
      return HeimdallFindings(subject: member, passed: prohibited, findings: [HeimdallValidationInfo.forSubject(member, 'Expected a field')]);
    }
    final missing = _missingFields(member, methodName);
    final matches = missing.isEmpty;
    final variables = matches ? member.fields.variables : missing;
    final findings = [
      for (final variable in variables)
        HeimdallValidationInfo(
          filePath: member.sourcePath,
          line: member.sourceLocationAt(variable.name.offset).line,
          column: member.sourceLocationAt(variable.name.offset).column,
          message: '${member.ownerName}.${variable.name.lexeme} should $description',
        ),
    ];
    return HeimdallFindings(subject: member, passed: prohibited ? !matches : matches, findings: findings);
  });
}

List<VariableDeclaration> _missingFields(FieldDeclaration field, String methodName) {
  final methods = field.owner.methods.where((method) => method.name.lexeme == methodName && !method.isSetter && !method.isStatic);
  final forwarded = <String>{};
  for (final method in methods) {
    forwarded.addAll(method.forwardedConstructorFieldNames);
  }
  return field.fields.variables.where((variable) => field.isStatic || !forwarded.contains(variable.name.lexeme)).toList();
}
