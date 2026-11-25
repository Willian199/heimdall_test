import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/util/extension/type_annotation_extension.dart';

/// Shared queries for [NamedType] nodes.
extension NamedTypeExtension on NamedType {
  /// The optionally prefixed name, without generic arguments or nullability.
  String get referenceName {
    final prefix = importPrefix?.name.lexeme;
    return prefix == null ? name.lexeme : '$prefix.${name.lexeme}';
  }

  /// The full type name, including generic arguments and nullability.
  String? get typeName {
    final buffer = StringBuffer()..write(referenceName);
    final arguments = typeArguments?.arguments.map((type) => type.typeName).toList();
    if (arguments != null) {
      if (arguments.any((argument) => argument == null)) {
        return null;
      }
      buffer
        ..write('<')
        ..write(arguments.whereType<String>().join(', '))
        ..write('>');
    }
    if (question != null) {
      buffer.write('?');
    }
    return buffer.toString();
  }
}
