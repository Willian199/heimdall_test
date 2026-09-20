import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/core/heimdall_condition.dart';
import 'package:heimdall_test/src/core/heimdall_predicate.dart';
import 'package:heimdall_test/src/core/heimdall_validation_info.dart';
import 'package:heimdall_test/src/features/member_features/helpers/member_assignability_rule_helpers.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_member.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_project.dart';

/// Creates a predicate that applies [test] to a member's declared field type name.
HeimdallPredicate<ClassMember> memberDeclaredTypeNamePredicate(
  String description,
  bool Function(String typeName) test,
) {
  return HeimdallPredicate(
    description,
    (item, _) {
      final typeName = _memberDeclaredTypeName(item);
      return typeName != null && test(typeName);
    },
  );
}

/// Creates a predicate that rejects matching declared field type names.
HeimdallPredicate<ClassMember> memberDoesNotHaveDeclaredTypeNamePredicate(
  String description,
  bool Function(String typeName) test,
) {
  return HeimdallPredicate(
    'not $description',
    (item, _) {
      final typeName = _memberDeclaredTypeName(item);
      return typeName == null || !test(typeName);
    },
  );
}

/// Creates a condition that applies [test] to a member's declared field type name.
HeimdallCondition<ClassMember> memberDeclaredTypeNameCondition(
  String description,
  bool Function(String typeName) test,
) {
  return HeimdallCondition(description, (item, _) {
    final typeName = _memberDeclaredTypeName(item);
    if (typeName != null && test(typeName)) {
      return HeimdallFindings(
        subject: item,
        passed: true,
      );
    }

    return HeimdallFindings(
      subject: item,
      passed: false,
      findings: [
        HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: item.line,
          message: '${item.ownerName}.${item.name} should $description',
        ),
      ],
    );
  });
}

/// Creates a condition that fails when a declared field type name matches [test].
HeimdallCondition<ClassMember> memberMustNotHaveDeclaredTypeNameCondition(
  String description,
  bool Function(String typeName) test,
) {
  return prohibitedMemberCondition(
    description,
    (item, _) {
      final typeName = _memberDeclaredTypeName(item);
      return typeName != null && test(typeName);
    },
  );
}

/// Returns whether a field's declared type is assignable to [typeName].
bool memberDeclaredTypeIsAssignableTo(
  ClassMember member,
  String typeName,
  HeimdallProject project,
) {
  final declaredTypeName = _memberDeclaredTypeName(member);
  if (declaredTypeName == null) return false;

  return typeNameIsAssignableToFrom(
    member.owner,
    declaredTypeName,
    typeName,
    project,
  );
}

String? _memberDeclaredTypeName(ClassMember member) {
  return member.isField ? member.type : null;
}
