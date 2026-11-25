import 'package:analyzer/dart/ast/ast.dart';

abstract final class _RegexPatterns {
  static final functionType = RegExp(r'\bFunction\s*[<(]');
  static final typeReference = RegExp(r'\b[A-Za-z_$][\w$]*(?:\.[A-Za-z_$][\w$]*)*\b');
}

/// An instantiated type that retains the source of its names and arguments.
final class TypeUse {
  /// Creates a type with already instantiated arguments and an origin.
  const TypeUse(this.name, this.arguments, this.nullable, this.source);

  /// Parses a type name while retaining the declaration that resolves its names.
  factory TypeUse.parse(String text, CompilationUnitMember source) {
    var value = text.trim();
    final nullable = value.endsWith('?');
    if (nullable) {
      value = value.substring(0, value.length - 1);
    }
    if (value.startsWith('(') ||
        _RegexPatterns.functionType.hasMatch(value) && (!value.contains('<') || value.indexOf('Function') < value.indexOf('<'))) {
      return TypeUse(value, const [], nullable, source);
    }
    final start = value.indexOf('<');
    if (start < 0 || !value.endsWith('>')) {
      return TypeUse(value, const [], nullable, source);
    }
    final arguments = <TypeUse>[];
    var depth = 0;
    var offset = start + 1;
    for (var i = offset; i < value.length - 1; i++) {
      final char = value[i];
      if ('<({'.contains(char)) {
        depth++;
      }
      if ('>)}'.contains(char)) {
        depth--;
      }
      if (char == ',' && depth == 0) {
        arguments.add(TypeUse.parse(value.substring(offset, i), source));
        offset = i + 1;
      }
    }
    arguments.add(TypeUse.parse(value.substring(offset, value.length - 1), source));
    return TypeUse(value.substring(0, start), arguments, nullable, source);
  }

  /// The type name before its generic arguments and outer nullability.
  final String name;

  /// Instantiated arguments, each retaining its own source scope.
  final List<TypeUse> arguments;

  /// Whether the type has an outer nullable suffix.
  final bool nullable;

  /// Declaration whose namespace resolves this type name.
  final CompilationUnitMember source;

  /// The textual type with its instantiated arguments and nullability.
  String get text => '$name${arguments.isEmpty ? '' : '<${arguments.map((item) => item.text).join(', ')}>'}${nullable ? '?' : ''}';

  /// Applies generic bindings without losing the origins of substituted types.
  TypeUse substitute(Map<String, TypeUse> bindings) {
    final bound = bindings[name];
    if (bound != null && arguments.isEmpty) {
      return TypeUse(bound.name, bound.arguments, nullable || bound.nullable, bound.source);
    }
    final replaced = name.replaceAllMapped(_RegexPatterns.typeReference, (match) => bindings[match[0]]?.text ?? match[0]!);
    return TypeUse(replaced, arguments.map((argument) => argument.substitute(bindings)).toList(), nullable, source);
  }
}
