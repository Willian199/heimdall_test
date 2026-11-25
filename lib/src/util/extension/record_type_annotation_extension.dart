import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/util/extension/type_annotation_extension.dart';

/// Shared queries for [RecordTypeAnnotation] nodes.
extension RecordTypeAnnotationExtension on RecordTypeAnnotation {
  /// The full type name, including generic arguments and nullability.
  String? get typeName {
    final positional = positionalFields.map((field) => field.type.typeName).toList();
    final named = <String>[];
    for (final field in namedFields?.fields ?? <RecordTypeAnnotationNamedField>[]) {
      final name = field.type.typeName;
      if (name == null) {
        return null;
      }
      named.add('$name ${field.name.lexeme}');
    }
    if (positional.contains(null)) {
      return null;
    }
    final fields = <String>[...positional.cast<String>(), if (named.isNotEmpty) '{${named.join(', ')}}'];
    final comma = positional.length == 1 && named.isEmpty ? ',' : '';
    return '(${fields.join(', ')}$comma)${question == null ? '' : '?'}';
  }
}
