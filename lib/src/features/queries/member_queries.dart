import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/core/heimdall_condition.dart';
import 'package:heimdall_test/src/core/heimdall_findings.dart';
import 'package:heimdall_test/src/core/heimdall_validation_info.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_member.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_project.dart';

/// Creates a member condition from a boolean [test].
HeimdallCondition<ClassMember> memberCondition(
  String description,
  bool Function(ClassMember item, HeimdallProject project) test,
) {
  return HeimdallCondition(description, (item, project) {
    final passed = test(item, project);
    final location = item.location;
    final findings = [
      HeimdallValidationInfo(
        filePath: item.sourcePath,
        line: item.line,
        column: location.columnNumber,
        message: passed ? '${item.ownerName}.${item.name} matches $description' : '${item.ownerName}.${item.name} should $description',
      ),
    ];
    return HeimdallFindings(
      subject: item,
      passed: passed,
      findings: findings,
    );
  });
}

/// Creates a member condition that fails when a prohibited structure is found.
HeimdallCondition<ClassMember> prohibitedMemberCondition(
  String description,
  bool Function(ClassMember item, HeimdallProject project) test, {
  int Function(ClassMember item)? offset,
}) {
  return HeimdallCondition(description, (item, project) {
    if (!test(item, project)) {
      return HeimdallFindings(
        subject: item,
        passed: true,
      );
    }

    final sourceOffset = offset?.call(item);

    final location = sourceOffset == null
        ? (
            line: item.location.lineNumber,
            column: item.location.columnNumber,
          )
        : item.sourceLocationAt(sourceOffset);

    final findings = [
      HeimdallValidationInfo(
        filePath: item.sourcePath,
        line: location.line,
        column: location.column,
        message: '${item.ownerName}.${item.name} must not $description',
      ),
    ];

    return HeimdallFindings(
      subject: item,
      passed: false,
      findings: findings,
    );
  });
}
