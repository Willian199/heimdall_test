import 'package:heimdall_test/heimdall_test.dart';

/// Shared queries for [FieldDeclaration] nodes.
extension FieldDeclarationExtension on FieldDeclaration {
  /// Returns variables absent from the selected method/getter in the same owner.
  List<VariableDeclaration> missingVariablesInMethod(String methodName, {required bool returnedList, bool everyReturn = false}) {
    final methods = owner.methods.where((method) => method.name.lexeme == methodName && !method.isSetter && !method.isStatic);
    final names = <String>{};
    for (final method in methods) {
      names.addAll(returnedList ? (everyReturn ? method.returnedListFieldNamesInEveryReturn : method.returnedListFieldNames) : method.parameterNames);
    }
    // Only instance state participates in these relations.
    return fields.variables.where((variable) => isStatic || !names.contains(variable.name.lexeme)).toList();
  }
}
