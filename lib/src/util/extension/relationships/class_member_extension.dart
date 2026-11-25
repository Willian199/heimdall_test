import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/util/extension/field_declaration_extension.dart';

/// Relationships queries for [ClassMember] nodes.
extension ClassMemberRelationshipsExtension on ClassMember {
  /// Internal relation check over every variable in a field declaration.
  bool fieldMatchesMethod(String methodName, {required bool returnedList, bool everyReturn = false}) => switch (this) {
    final FieldDeclaration field => field.missingVariablesInMethod(methodName, returnedList: returnedList, everyReturn: everyReturn).isEmpty,
    _ => false,
  };
}
