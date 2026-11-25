import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/util/extension/field_declaration_extension.dart';

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
    final missing = member.missingVariablesInMethod(methodName, returnedList: returnedList, everyReturn: everyReturn);
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
