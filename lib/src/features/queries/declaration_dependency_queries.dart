import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

import 'package:heimdall_test/src/core.dart';

/// Returns directives visible to [item], including its owning library imports.
List<Directive> dependenciesFrom(
  CompilationUnitMember item,
  HeimdallProject project,
) {
  final file = project.filesByPath[item.sourcePath];
  if (file == null) return const [];
  return [
    ...file.typeReferenceDirectives,
    if (file.partOfDirectives.isNotEmpty)
      for (final owner in project.files)
        if (owner.partDirectives.any((part) => part.targetFiles.contains(file))) ...owner.typeReferenceDirectives,
  ];
}

/// Returns local type dependencies that [item] references.
List<DeclarationDependency> declarationDependenciesFrom(
  CompilationUnitMember item,
  HeimdallProject project,
) {
  final references = _ResolvedReferenceVisitor()..collect(item);
  return [
    for (final dependency in dependenciesFrom(item, project))
      for (final resolvedTarget in dependency.resolvedTargets)
        for (final target in project.visibleTypeDeclarationsThroughTarget(
          dependency,
          resolvedTarget.file,
        ))
          if (_declarationReferencesTarget(
            item,
            target,
            dependency,
            references,
          ))
            DeclarationDependency(
              directive: dependency,
              target: target,
              targetUri: resolvedTarget.uri,
            ),
  ];
}

/// Returns only target declarations from [declarationDependenciesFrom].
List<CompilationUnitMember> targetDeclarations(
  CompilationUnitMember item,
  HeimdallProject project,
) {
  return declarationDependenciesFrom(
    item,
    project,
  ).map((dependency) => dependency.target).toList();
}

/// Dependency edge from a declaration to another declaration.
final class DeclarationDependency {
  /// Creates a declaration dependency edge.
  const DeclarationDependency({
    required this.directive,
    required this.target,
    required this.targetUri,
  });

  /// Directive that introduced the dependency.
  final Directive directive;

  /// Referenced target declaration.
  final CompilationUnitMember target;

  /// URI branch that exposed [target].
  final String targetUri;
}

bool _declarationReferencesTarget(
  CompilationUnitMember item,
  CompilationUnitMember target,
  Directive directive,
  _ResolvedReferenceVisitor references,
) {
  final targetElement = target.declaredFragment?.element;
  if (targetElement != null && references.elements.contains(targetElement)) {
    return true;
  }

  // Conditional directives intentionally model every possible platform branch,
  // while the analyzer binds identifiers only to the active branch.
  final needsSyntaxFallback = directive.targetUris.length > 1 || targetElement == null || references.hasUnresolvedIdentifiers;
  if (!needsSyntaxFallback) return false;

  final targetName = target.name;
  if (targetName.startsWith('<')) return false;
  final visitor = _IdentifierReferenceVisitor(
    targetName,
    importPrefix: directive is ImportDirective ? directive.prefix?.name : null,
  );
  item.accept(visitor);
  return visitor.found;
}

final class _ResolvedReferenceVisitor extends RecursiveAstVisitor<void> {
  final Set<Element> elements = {};
  bool hasUnresolvedIdentifiers = false;

  void collect(AstNode node) => node.accept(this);

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    final element = node.element;
    if (element == null) {
      hasUnresolvedIdentifiers = true;
    } else {
      elements.add(element);
    }
    super.visitSimpleIdentifier(node);
  }

  @override
  void visitNamedType(NamedType node) {
    final element = node.element;
    if (element == null) {
      hasUnresolvedIdentifiers = true;
    } else {
      elements.add(element);
    }
    super.visitNamedType(node);
  }
}

final class _IdentifierReferenceVisitor extends RecursiveAstVisitor<void> {
  _IdentifierReferenceVisitor(this.targetName, {required this.importPrefix});

  final String targetName;
  final String? importPrefix;
  final List<Set<String>> _scopes = [<String>{}];
  bool found = false;

  bool get _isLocalTargetName => _scopes.any((scope) => scope.contains(targetName));

  void _declare(String name) {
    _scopes.last.add(name);
  }

  Iterable<String> _typeParameterNames(TypeParameterList? typeParameters) {
    return typeParameters?.typeParameters.map((parameter) => parameter.name.lexeme) ?? const <String>[];
  }

  Iterable<String> _classNamePartTypeParameterNames(ClassNamePart namePart) {
    return _typeParameterNames(
      namePart.childEntities.whereType<TypeParameterList>().firstOrNull,
    );
  }

  void _withScope(void Function() visit, {Iterable<String> names = const []}) {
    _scopes.add(names.toSet());
    visit();
    _scopes.removeLast();
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    _withScope(
      () => super.visitClassDeclaration(node),
      names: _classNamePartTypeParameterNames(node.namePart),
    );
  }

  @override
  void visitEnumDeclaration(EnumDeclaration node) {
    _withScope(
      () => super.visitEnumDeclaration(node),
      names: _classNamePartTypeParameterNames(node.namePart),
    );
  }

  @override
  void visitExtensionDeclaration(ExtensionDeclaration node) {
    _withScope(
      () => super.visitExtensionDeclaration(node),
      names: _typeParameterNames(node.typeParameters),
    );
  }

  @override
  void visitGenericTypeAlias(GenericTypeAlias node) {
    _withScope(
      () => super.visitGenericTypeAlias(node),
      names: _typeParameterNames(node.typeParameters),
    );
  }

  @override
  void visitMixinDeclaration(MixinDeclaration node) {
    _withScope(
      () => super.visitMixinDeclaration(node),
      names: _typeParameterNames(node.typeParameters),
    );
  }

  @override
  void visitAnnotation(Annotation node) {
    final expectedName = importPrefix == null ? targetName : '$importPrefix.$targetName';
    if (node.name.name == expectedName) {
      found = true;
      return;
    }
    super.visitAnnotation(node);
  }

  @override
  void visitNamedType(NamedType node) {
    if (_matchesNamedType(node) && !_isLocalTargetName) {
      found = true;
      return;
    }
    super.visitNamedType(node);
  }

  @override
  void visitBlock(Block node) {
    _withScope(() => super.visitBlock(node));
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _declare(node.name.lexeme);
    _withScope(
      () {
        node.returnType?.accept(this);
        node.functionExpression.parameters?.accept(this);
        final parameterNames =
            node.functionExpression.parameters?.parameters.map((parameter) => parameter.name?.lexeme).whereType<String>() ?? const <String>[];
        _withScope(
          () => node.functionExpression.body.accept(this),
          names: parameterNames,
        );
      },
      names: _typeParameterNames(node.functionExpression.typeParameters),
    );
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    _withScope(
      () {
        node.parameters?.accept(this);
        final parameterNames = node.parameters?.parameters.map((parameter) => parameter.name?.lexeme).whereType<String>() ?? const <String>[];
        _withScope(() => node.body.accept(this), names: parameterNames);
      },
      names: _typeParameterNames(node.typeParameters),
    );
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final target = node.target;
    if (target != null && _matchesTargetExpression(target) && !_isLocalTargetName) {
      found = true;
      return;
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _withScope(
      () {
        node.returnType?.accept(this);
        node.parameters?.accept(this);
        final parameterNames = node.parameters?.parameters.map((parameter) => parameter.name?.lexeme).whereType<String>() ?? const <String>[];
        _withScope(() => node.body.accept(this), names: parameterNames);
      },
      names: _typeParameterNames(node.typeParameters),
    );
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    node.parameters.accept(this);
    final parameterNames = node.parameters.parameters.map((parameter) => parameter.name?.lexeme).whereType<String>();
    _withScope(() => node.body.accept(this), names: parameterNames);
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (_matchesTargetExpression(node.prefix) && !_isLocalTargetName || _matchesTargetExpression(node) && !_isLocalTargetName) {
      found = true;
      return;
    }
    super.visitPrefixedIdentifier(node);
  }

  @override
  void visitConstructorName(ConstructorName node) {
    if (_matchesNamedType(node.type) && !_isLocalTargetName) {
      found = true;
      return;
    }
    super.visitConstructorName(node);
  }

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    node.initializer?.accept(this);
    _declare(node.name.lexeme);
  }

  bool _matchesNamedType(NamedType node) {
    return node.name.lexeme == targetName && node.importPrefix?.name.lexeme == importPrefix;
  }

  bool _matchesTargetExpression(Expression expression) {
    if (importPrefix == null) {
      return expression is SimpleIdentifier && expression.name == targetName ||
          expression is PrefixedIdentifier && expression.prefix.name == targetName;
    }
    return expression is PrefixedIdentifier && expression.prefix.name == importPrefix && expression.identifier.name == targetName;
  }
}
