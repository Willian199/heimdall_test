import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/line_info.dart';

import 'package:heimdall_test/src/features/queries/type_annotation_queries.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_declaration.dart';

final _contexts = Expando<_MemberContext>('heimdall.memberContext');

/// Adds Heimdall convenience metadata to [ClassMember].
///
/// The member remains the real analyzer node. This extension only exposes
/// helpers for naming, modifiers, ownership, and source location.
///
/// Example:
/// ```dart
/// final mutableFields = declaration.members.where(
///   (member) => member.isField && !member.isFinal,
/// );
/// ```
extension HeimdallMember on ClassMember {
  /// Human-readable member name.
  ///
  /// Multi-variable fields are returned as a comma-separated textual list.
  String get name => _context.name;

  /// One-based line where the member starts.
  int get line => location.lineNumber;

  /// Analyzer source location where the member starts.
  CharacterLocation get location => _context.location;

  /// Source location for [sourceOffset] inside the member file.
  ({int line, int column}) sourceLocationAt(int sourceOffset) {
    final location = _context.lineInfo.getLocation(sourceOffset);
    return (line: location.lineNumber, column: location.columnNumber);
  }

  /// Declaration that owns this member.
  CompilationUnitMember get owner => _context.owner;

  /// Name of the declaration that owns this member.
  String get ownerName => owner.name;

  /// Absolute path of the source file.
  String get sourcePath => _context.sourcePath;

  /// Path relative to the imported root.
  String get relativePath => _context.relativePath;

  /// Textual method return type or field type, when available.
  String? get type => _context.type;

  /// Parameters declared by executable members.
  List<FormalParameter> get parameters => _context.parameters;

  /// AST roots that can contain executable references inside this member.
  List<AstNode> get executableRoots => _context.executableRoots;

  /// `true` para [FieldDeclaration].
  bool get isField => _context.isField;

  /// `true` para [MethodDeclaration].
  bool get isMethod => _context.isMethod;

  /// `true` para [ConstructorDeclaration].
  bool get isConstructor => _context.isConstructor;

  /// `true` for static fields or methods.
  bool get isStatic => _context.isStatic;

  /// `true` for fields declared as `final`.
  bool get isFinal => _context.isFinal;

  /// `true` for fields or constructors declared as `const`.
  bool get isConst => _context.isConst;

  /// `true` for factory constructors.
  bool get isFactory => _context.isFactory;

  /// Annotation type names declared on this member.
  List<String> get annotations => _context.annotations;

  /// Annotation nodes declared on this member.
  List<Annotation> get annotationNodes => _context.annotationNodes;

  /// `true` when the name starts with `_`.
  bool get isPrivate => _context.isPrivate;

  /// `true` when the name does not start with `_`.
  bool get isPublic => !isPrivate;

  _MemberContext get _context {
    final context = _contexts[this];
    if (context == null) {
      throw StateError('ClassMember has no Heimdall member context attached.');
    }
    return context;
  }
}

/// Attaches source context to a [ClassMember].
///
/// Called by the importer so [HeimdallMember.line] can point at the correct
/// source line.
void attachMemberContext({
  required ClassMember node,
  required CompilationUnitMember owner,
  required String sourcePath,
  required String relativePath,
  required LineInfo lineInfo,
}) {
  if (_contexts[node] != null) {
    throw StateError('ClassMember already has Heimdall member context attached.');
  }
  _contexts[node] = _MemberContext(
    node: node,
    owner: owner,
    sourcePath: sourcePath,
    relativePath: relativePath,
    lineInfo: lineInfo,
  );
}

final class _MemberContext {
  _MemberContext({
    required ClassMember node,
    required this.owner,
    required this.sourcePath,
    required this.relativePath,
    required this.lineInfo,
  }) : name = _nameOf(node),
       location = lineInfo.getLocation(node.offset),
       type = _typeOf(node),
       isField = node is FieldDeclaration,
       isMethod = node is MethodDeclaration,
       isConstructor = node is ConstructorDeclaration,
       isStatic = node is FieldDeclaration ? node.isStatic : node is MethodDeclaration && node.isStatic,
       isFinal = node is FieldDeclaration && node.fields.isFinal,
       isConst = node is FieldDeclaration ? node.fields.isConst : node is ConstructorDeclaration && node.constKeyword != null,
       isFactory = node is ConstructorDeclaration && node.factoryKeyword != null,
       annotationNodes = List.unmodifiable(node.metadata),
       parameters = List.unmodifiable(_parametersOf(node)),
       executableRoots = List.unmodifiable(_executableRootsOf(node)) {
    annotations = List.unmodifiable(
      annotationNodes.map((annotation) => annotation.name.name),
    );
    isPrivate = name.startsWith('_');
  }

  final CompilationUnitMember owner;
  final String sourcePath;
  final String relativePath;
  final LineInfo lineInfo;
  final String name;
  final CharacterLocation location;
  final String? type;
  final bool isField;
  final bool isMethod;
  final bool isConstructor;
  final bool isStatic;
  final bool isFinal;
  final bool isConst;
  final bool isFactory;
  late final List<String> annotations;
  final List<Annotation> annotationNodes;
  final List<FormalParameter> parameters;
  final List<AstNode> executableRoots;
  late final bool isPrivate;
}

String _nameOf(ClassMember member) {
  if (member is FieldDeclaration) {
    return member.fields.variables.map((variable) => variable.name.lexeme).join(', ');
  }
  if (member is MethodDeclaration) return member.name.lexeme;
  if (member is ConstructorDeclaration) return member.name?.lexeme ?? 'new';
  return member.toSource().split(RegExp(r'\s+')).take(3).join(' ');
}

String? _typeOf(ClassMember member) {
  if (member is MethodDeclaration) {
    return typeAnnotationName(member.returnType);
  }
  if (member is FieldDeclaration) {
    return typeAnnotationName(member.fields.type);
  }
  return null;
}

List<FormalParameter> _parametersOf(ClassMember member) {
  return switch (member) {
    MethodDeclaration(:final parameters) => parameters?.parameters ?? const <FormalParameter>[],
    ConstructorDeclaration(:final parameters) => parameters.parameters,
    _ => const <FormalParameter>[],
  };
}

List<AstNode> _executableRootsOf(ClassMember member) {
  if (member is MethodDeclaration) return [member.body];
  if (member is ConstructorDeclaration) return [...member.initializers, member.body];
  if (member is FieldDeclaration) {
    return member.fields.variables.map((variable) => variable.initializer).whereType<Expression>().toList();
  }
  return const [];
}
