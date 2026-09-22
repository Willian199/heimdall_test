import 'package:heimdall_test/heimdall_test.dart';

/// Internal relation check over every variable in a field declaration.
bool fieldMatchesMethod(ClassMember member, String methodName, {required bool returnedList, bool everyReturn = false}) {
  return member is FieldDeclaration && missingFieldVariables(member, methodName, returnedList: returnedList, everyReturn: everyReturn).isEmpty;
}

/// Reports each missing variable at its own location.
HeimdallCondition<ClassMember> fieldRelationshipCondition(
  String methodName, {
  required bool returnedList,
  bool everyReturn = false,
  bool prohibited = false,
}) {
  final relation = returnedList
      ? everyReturn
            ? 'be included in every returned list of'
            : 'be included in a returned list of'
      : 'have a matching parameter in';
  final description = '${prohibited ? 'not ' : ''}$relation $methodName';
  return HeimdallCondition(description, (member, _) {
    if (member is! FieldDeclaration) {
      return HeimdallFindings(subject: member, passed: prohibited, findings: [HeimdallValidationInfo.forSubject(member, 'Expected a field')]);
    }
    final missing = missingFieldVariables(member, methodName, returnedList: returnedList, everyReturn: everyReturn);
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

/// Returns variables absent from the selected method/getter in the same owner.
List<VariableDeclaration> missingFieldVariables(FieldDeclaration field, String methodName, {required bool returnedList, bool everyReturn = false}) {
  final methods = field.owner.methods.where((method) => method.name.lexeme == methodName && !method.isSetter && !method.isStatic);
  final names = <String>{};
  for (final method in methods) {
    names.addAll(returnedList ? (everyReturn ? method.returnedListFieldNamesInEveryReturn : method.returnedListFieldNames) : method.parameterNames);
  }
  // Only instance state participates in these relations.
  return field.fields.variables.where((variable) => field.isStatic || !names.contains(variable.name.lexeme)).toList();
}
