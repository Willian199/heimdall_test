import 'package:analyzer/source/line_info.dart';
import 'package:heimdall_test/heimdall_test.dart';

final _contexts = Expando<_DeclarationContext>('heimdall.declarationContext');

/// Adds Heimdall convenience metadata to [CompilationUnitMember].
///
/// The declaration remains the real analyzer node. This extension only exposes
/// common rule helpers such as name, source path, line, annotations, members,
/// and Dart modifiers.
///
/// Example:
/// ```dart
/// final services = project.declarations.where(
///   (declaration) => declaration.name.endsWith('Service'),
/// );
/// ```
extension HeimdallDeclaration on CompilationUnitMember {
  /// Human-readable declaration name.
  ///
  /// For classes, mixins, enums, aliases, and functions this returns the
  /// declared name. For declarations not handled explicitly, it returns a short
  /// source-based representation.
  String get name => _context.name;

  /// Absolute path of the source file.
  String get sourcePath => _context.sourcePath;

  /// Path relative to the imported root.
  String get relativePath => _context.relativePath;

  /// One-based line where the declaration starts.
  int get line => location.lineNumber;

  /// Analyzer source location where the declaration starts.
  CharacterLocation get location => _context.location;

  /// Source location for [sourceOffset] inside the declaration file.
  ({int line, int column}) sourceLocationAt(int sourceOffset) {
    final location = _context.lineInfo.getLocation(sourceOffset);
    return (line: location.lineNumber, column: location.columnNumber);
  }

  /// Annotation type names declared on this node.
  List<String> get annotations => _context.annotations;

  /// Annotation nodes declared on this node.
  List<Annotation> get annotationNodes => _context.annotationNodes;

  /// Members declared in the declaration body, when it has one.
  ///
  /// Returns an empty list for nodes without members, such as top-level
  /// functions.
  List<ClassMember> get members => _context.members;

  /// Constructor declarations owned by this declaration.
  List<ConstructorDeclaration> get constructors => _context.constructors;

  /// Number of declared constructors, including an extension type's primary constructor.
  int get constructorCount => constructors.length + (this is ExtensionTypeDeclaration ? 1 : 0);

  /// Total number of parameters across declared constructors.
  int get constructorParameterCount =>
      constructors.fold<int>(0, (count, constructor) => count + constructor.parameters.parameters.length) +
      (this is ExtensionTypeDeclaration ? (this as ExtensionTypeDeclaration).primaryConstructor.formalParameters.parameters.length : 0);

  /// Method declarations owned by this declaration.
  List<MethodDeclaration> get methods => _context.methods;

  /// Field declarations owned by this declaration.
  List<FieldDeclaration> get fields => _context.fields;

  /// Individual field variables owned by this declaration.
  List<VariableDeclaration> get fieldVariables => _context.fieldVariables;

  /// `true` when the name starts with `_` or an extension has no name.
  bool get isPrivate => _context.isPrivate;

  /// `true` when the name does not start with `_`.
  bool get isPublic => !isPrivate;

  /// `true` para [EnumDeclaration].
  bool get isEnum => this is EnumDeclaration;

  /// `true` para [MixinDeclaration].
  bool get isMixin => this is MixinDeclaration;

  /// `true` para [ExtensionDeclaration].
  bool get isExtension => this is ExtensionDeclaration;

  /// `true` para [ExtensionTypeDeclaration].
  bool get isExtensionType => this is ExtensionTypeDeclaration;

  /// `true` for declarations that `Heimdall.classes()` treats as types.
  ///
  /// In Dart, this includes classes, mixins, enums, extensions, and extension
  /// types.
  bool get isTypeDeclaration => _context.isTypeDeclaration;

  /// `true` for classes with the `abstract` modifier.
  bool get isAbstract => _context.isAbstract;

  /// `true` for classes with the `sealed` modifier.
  bool get isSealed => _context.isSealed;

  /// `true` for classes or mixins with the `base` modifier.
  bool get isBase => _context.isBase;

  /// `true` for classes with the `interface` modifier.
  bool get isInterface => _context.isInterface;

  /// `true` for classes with the `final` modifier.
  bool get isFinal => _context.isFinal;

  _DeclarationContext get _context {
    final context = _contexts[this];
    if (context == null) {
      throw StateError(
        'CompilationUnitMember has no Heimdall source context attached.',
      );
    }
    return context;
  }
}

/// Attaches source-file context to an analyzer declaration.
///
/// Used by [HeimdallFileImporter]. Library consumers normally do not need to
/// call this function directly.
void attachDeclarationContext({
  required CompilationUnitMember node,
  required String sourcePath,
  required String relativePath,
  required LineInfo lineInfo,
}) {
  if (_contexts[node] != null) {
    throw StateError('CompilationUnitMember already has Heimdall source context attached.');
  }
  _contexts[node] = _DeclarationContext(
    node: node,
    sourcePath: sourcePath,
    relativePath: relativePath,
    lineInfo: lineInfo,
  );
}

String _nameOf(CompilationUnitMember member) {
  if (member is ClassDeclaration) return member.namePart.typeName.lexeme;
  if (member is MixinDeclaration) return member.name.lexeme;
  if (member is EnumDeclaration) return member.namePart.typeName.lexeme;
  if (member is ExtensionDeclaration) {
    return member.name?.lexeme ?? '<anonymous extension>';
  }
  if (member is ExtensionTypeDeclaration) {
    return member.primaryConstructor.typeName.lexeme;
  }
  if (member is TypeAlias) return member.name.lexeme;
  if (member is FunctionDeclaration) return member.name.lexeme;
  if (member is TopLevelVariableDeclaration) {
    return member.variables.variables.map((variable) => variable.name.lexeme).join(', ');
  }
  return member.toSource().split(RegExp(r'\s+')).take(3).join(' ');
}

List<ClassMember> _membersOf(CompilationUnitMember member) {
  if (member is ClassDeclaration) return _membersFromClassBody(member.body);
  if (member is MixinDeclaration) return member.body.members;
  if (member is EnumDeclaration) return member.body.members;
  if (member is ExtensionDeclaration) return member.body.members;
  if (member is ExtensionTypeDeclaration) {
    return _membersFromClassBody(member.body);
  }
  return const [];
}

List<ClassMember> _membersFromClassBody(ClassBody body) {
  return switch (body) {
    BlockClassBody(:final members) => members,
    _ => const <ClassMember>[],
  };
}

final class _DeclarationContext {
  _DeclarationContext({
    required CompilationUnitMember node,
    required this.sourcePath,
    required this.relativePath,
    required this.lineInfo,
  }) : name = _nameOf(node),
       location = lineInfo.getLocation(node.offset),
       annotationNodes = List.unmodifiable(node.metadata),
       members = List.unmodifiable(_membersOf(node)),
       isTypeDeclaration =
           node is ClassDeclaration ||
           node is MixinDeclaration ||
           node is EnumDeclaration ||
           node is ExtensionDeclaration ||
           node is ExtensionTypeDeclaration,
       isAbstract = node is ClassDeclaration && node.abstractKeyword != null,
       isSealed = node is ClassDeclaration && node.sealedKeyword != null,
       isBase = node is ClassDeclaration && node.baseKeyword != null || node is MixinDeclaration && node.baseKeyword != null,
       isInterface = node is ClassDeclaration && node.interfaceKeyword != null,
       isFinal = node is ClassDeclaration && node.finalKeyword != null {
    annotations = List.unmodifiable(
      annotationNodes.map((annotation) => annotation.name.name),
    );
    constructors = List.unmodifiable(members.whereType<ConstructorDeclaration>());
    methods = List.unmodifiable(members.whereType<MethodDeclaration>());
    fields = List.unmodifiable(members.whereType<FieldDeclaration>());
    fieldVariables = List.unmodifiable(
      fields.expand((field) => field.fields.variables),
    );
    isPrivate = name.startsWith('_') || node is ExtensionDeclaration && node.name == null;
  }

  final String sourcePath;
  final String relativePath;
  final LineInfo lineInfo;
  final String name;
  final CharacterLocation location;
  late final List<String> annotations;
  final List<Annotation> annotationNodes;
  final List<ClassMember> members;
  late final List<ConstructorDeclaration> constructors;
  late final List<MethodDeclaration> methods;
  late final List<FieldDeclaration> fields;
  late final List<VariableDeclaration> fieldVariables;
  late final bool isPrivate;
  final bool isTypeDeclaration;
  final bool isAbstract;
  final bool isSealed;
  final bool isBase;
  final bool isInterface;
  final bool isFinal;
}
