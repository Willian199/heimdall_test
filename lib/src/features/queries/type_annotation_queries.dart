import 'package:analyzer/dart/ast/ast.dart';

/// Returns a type name assembled from analyzer AST nodes.
String? typeAnnotationName(TypeAnnotation? type) {
  return switch (type) {
    NamedType() => _namedTypeName(type),
    _ => null,
  };
}

String? _namedTypeName(NamedType type) {
  final buffer = StringBuffer()..write(namedTypeReferenceName(type));

  final arguments = type.typeArguments?.arguments.map(typeAnnotationName).toList();
  if (arguments != null) {
    if (arguments.any((argument) => argument == null)) return null;
    buffer
      ..write('<')
      ..write(arguments.whereType<String>().join(', '))
      ..write('>');
  }

  if (type.question != null) buffer.write('?');
  return buffer.toString();
}

/// Returns the optionally prefixed name of [type], without generic arguments.
String namedTypeReferenceName(NamedType type) {
  final prefix = type.importPrefix?.name.lexeme;
  return prefix == null ? type.name.lexeme : '$prefix.${type.name.lexeme}';
}
