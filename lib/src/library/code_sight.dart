import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_lookup_queries.dart';
import 'package:heimdall_test/src/features/queries/type_annotation_queries.dart';

/// Built-in rules for source-code hygiene checks.
final class HeimdallCodeSight {
  /// Creates the built-in code sight rule provider.
  const HeimdallCodeSight();

  /// Ensures imported files do not import `dart:mirrors`.
  HeimdallRule<HeimdallSourceFile> shouldNotImportDartMirrors() {
    return Heimdall.files().should().noImportUri('dart:mirrors').as('code should not import dart:mirrors');
  }

  /// Ensures imported files do not import [packageName].
  HeimdallRule<HeimdallSourceFile> shouldNotImportPackage(
    String packageName,
  ) {
    final escapedPackageName = RegExp.escape(packageName);
    return Heimdall.files().should().noImportUriMatching(RegExp('^package:$escapedPackageName/')).as('code should not import package:$packageName');
  }

  /// Ensures all imported files parse without analyzer errors.
  HeimdallRule<HeimdallSourceFile> shouldParse() {
    return Heimdall.files().should().haveNoParseErrors().as('code should parse');
  }

  /// Ensures [pathPattern] is empty among imported files.
  ///
  /// This accepts existing directories in the filesystem; it only fails when
  /// imported files are found under the path.
  HeimdallRule<HeimdallSourceFile> pathShouldBeEmpty(String pathPattern) =>
      _emptyPathRule(pathPattern, description: 'path $pathPattern should be empty');

  /// Ensures [pathPattern] does not exist among imported files.
  ///
  /// Because Heimdall imports files rather than directories, this has the same
  /// runtime behavior as [pathShouldBeEmpty] and uses stricter wording for
  /// rules that ban a legacy path.
  HeimdallRule<HeimdallSourceFile> pathShouldNotExist(String pathPattern) =>
      _emptyPathRule(pathPattern, description: 'path $pathPattern should not exist');

  /// Ensures public declarations in [pathPattern] do not expose `dynamic`.
  ///
  /// Use [ignoredPathPatterns] to skip generated, legacy, or intentionally
  /// dynamic files. Patterns use the same semantics as [pathMatches]; a pattern
  /// without `.dart` also matches the same path with `.dart` appended.
  ///
  /// Use [ignoredDeclarationNames] and [ignoredDeclarationNamePatterns] to skip
  /// specific public declarations inside otherwise validated files.
  HeimdallRule<CompilationUnitMember> publicSignaturesShouldNotUseDynamic({
    String pathPattern = '**',
    Iterable<String> ignoredPathPatterns = const [],
    Iterable<String> ignoredDeclarationNames = const [],
    Iterable<RegExp> ignoredDeclarationNamePatterns = const [],
  }) {
    final ignoredPathPatternList = ignoredPathPatterns.toList();
    final ignoredDeclarationNameSet = ignoredDeclarationNames.toSet();
    final ignoredDeclarationNamePatternList = ignoredDeclarationNamePatterns.toList();
    return HeimdallRule(
      descriptionPrefix: 'public signatures',
      selector: (project) => project.publicDeclarations.where(
        (declaration) =>
            pathMatches(declaration.relativePath, pathPattern) &&
            !_isIgnoredPublicSignatureDeclaration(
              declaration,
              ignoredPathPatterns: ignoredPathPatternList,
              ignoredDeclarationNames: ignoredDeclarationNameSet,
              ignoredDeclarationNamePatterns: ignoredDeclarationNamePatternList,
            ),
      ),
      predicate: const HeimdallPredicate(
        'public declarations',
        _allDeclarations,
      ),
      condition: HeimdallCondition('not use dynamic', (
        item,
        project,
      ) {
        final findings = _publicDynamicSignatureFindings(item, project);
        return HeimdallFindings(
          subject: item,
          passed: findings.isEmpty,
          findings: findings,
        );
      }),
    );
  }

  /// Ensures files in [pathPattern] declare at most one public class.
  HeimdallRule<HeimdallSourceFile> shouldHaveAtMostOnePublicClassPerFile({
    String pathPattern = '**',
  }) {
    return Heimdall.files().that().resideInPath(pathPattern).should().haveAtMostOnePublicClass().as('files should have at most one public class');
  }

  /// Requires same-package imports to use relative URIs, including every
  /// conditional branch and targets excluded from the imported source set.
  ///
  /// Other package imports and SDK imports are accepted. This is a style check;
  /// use [preferRelativeUris] to also validate URI syntax and package boundaries.
  HeimdallRule<HeimdallSourceFile> preferRelativeImports({
    String pathPattern = '**',
  }) => Heimdall.files().that().resideInPath(pathPattern).should().satisfy(_preferRelativeImports()).as('files should prefer relative imports');

  /// Requires imports to use `package:` or SDK URIs instead of relative URIs.
  ///
  /// Checks every conditional branch without requiring imported targets.
  /// This is a style check; use [preferPackageUris] for the complete URI policy.
  HeimdallRule<HeimdallSourceFile> preferPackageImports({
    String pathPattern = '**',
  }) => Heimdall.files().that().resideInPath(pathPattern).should().satisfy(_preferPackageImports()).as('files should prefer package imports');

  /// Requires relative same-package imports/exports and `package:` external ones.
  ///
  /// SDK URIs are accepted for imports/exports. Parts and URI-based part-ofs
  /// must be relative and stay in the same package; named part-ofs are accepted.
  /// Checks URI syntax and every conditional branch without reading files.
  /// Uses the checked project's package metadata. Import each package separately.
  HeimdallRule<HeimdallSourceFile> preferRelativeUris({
    String pathPattern = '**',
  }) => Heimdall.files().that().resideInPath(pathPattern).should().satisfy(_preferRelativeUris()).as('files should prefer relative URIs');

  /// Requires imports/exports to use `package:` or SDK URIs.
  ///
  /// Parts and URI-based part-ofs must remain relative within the same package;
  /// named part-ofs are accepted. Checks syntax and every conditional branch.
  /// Uses the checked project's package metadata. Import each package separately.
  /// Rules use imported metadata only and do not read or create files.
  HeimdallRule<HeimdallSourceFile> preferPackageUris({
    String pathPattern = '**',
  }) => Heimdall.files().that().resideInPath(pathPattern).should().satisfy(_preferPackageUris()).as('files should prefer package URIs');

  HeimdallCondition<HeimdallSourceFile> _preferRelativeImports() {
    return HeimdallCondition('prefer relative imports', (file, project) {
      final ownPackagePrefix = project.packageName == null ? null : 'package:${project.packageName}/';
      final findings = [
        if (ownPackagePrefix != null)
          for (final directive in file.packageImports)
            for (final target in directive.targetUris)
              if (target.startsWith(ownPackagePrefix))
                HeimdallValidationInfo(
                  filePath: file.absolutePath,
                  line: directive.line,
                  message: 'Use relative import instead of $target',
                ),
      ];
      return HeimdallFindings(subject: file, passed: findings.isEmpty, findings: findings);
    });
  }

  HeimdallCondition<HeimdallSourceFile> _preferPackageImports() {
    return HeimdallCondition('prefer package imports', (file, _) {
      final findings = [
        for (final directive in file.relativeImports)
          for (final target in directive.targetUris)
            if (!target.contains(':'))
              HeimdallValidationInfo(
                filePath: file.absolutePath,
                line: directive.line,
                message: 'Use package import instead of $target',
              ),
      ];
      return HeimdallFindings(subject: file, passed: findings.isEmpty, findings: findings);
    });
  }

  /// Requires relative internal URIs using cached source-file metadata.
  HeimdallCondition<HeimdallSourceFile> _preferRelativeUris() {
    return HeimdallCondition('prefer relative URIs', (file, project) {
      final findings = <HeimdallValidationInfo>[];
      for (final reference in file.sourceUris) {
        final uri = reference.uri;
        final allowed =
            reference.isValid &&
            switch (uri!.scheme) {
              'dart' => !reference.isPart,
              'package' => !reference.isPart && project.packageName != null && uri.pathSegments.first != project.packageName,
              '' => reference.relativeDestination!.toString().startsWith(project.packageRootUri.toString()),
              _ => false,
            };
        if (!allowed) {
          findings.add(
            HeimdallValidationInfo(
              filePath: file.absolutePath,
              line: reference.directive.line,
              message: 'URI policy: invalid ${reference.directive.runtimeType} URI ${reference.target}',
            ),
          );
        }
      }
      return HeimdallFindings(subject: file, passed: findings.isEmpty, findings: findings);
    });
  }

  /// Requires package URIs for imports/exports while keeping parts relative.
  HeimdallCondition<HeimdallSourceFile> _preferPackageUris() {
    return HeimdallCondition('prefer package URIs', (file, project) {
      final findings = <HeimdallValidationInfo>[];
      for (final reference in file.sourceUris) {
        final uri = reference.uri;
        final allowed =
            reference.isValid &&
            switch (uri!.scheme) {
              'dart' => !reference.isPart,
              'package' => !reference.isPart && project.packageName != null,
              '' => reference.isPart && reference.relativeDestination!.toString().startsWith(project.packageRootUri.toString()),
              _ => false,
            };
        if (!allowed) {
          findings.add(
            HeimdallValidationInfo(
              filePath: file.absolutePath,
              line: reference.directive.line,
              message: 'URI policy: invalid ${reference.directive.runtimeType} URI ${reference.target}',
            ),
          );
        }
      }
      return HeimdallFindings(subject: file, passed: findings.isEmpty, findings: findings);
    });
  }

  /// Ensures a single public class has a file name matching its class name.
  HeimdallRule<HeimdallSourceFile> publicClassNameShouldMatchFileName({
    String pathPattern = '**',
  }) {
    return Heimdall.files()
        .that()
        .resideInPath(pathPattern)
        .should()
        .havePublicClassNameMatchingFileName()
        .as('public class name should match file name');
  }

  /// Ensures imported files do not use `part of`.
  HeimdallRule<HeimdallSourceFile> shouldNotUsePartOf() {
    return HeimdallRule(
      descriptionPrefix: 'code',
      selector: (project) => project.files,
      predicate: const HeimdallPredicate('all files', _allFiles),
      condition: HeimdallCondition('not use part of', (item, _) {
        final findings = item.partOfDirectives
            .map(
              (directive) => HeimdallValidationInfo(
                filePath: item.absolutePath,
                line: directive.line,
                message: 'uses part of',
              ),
            )
            .toList();
        return HeimdallFindings(
          subject: item,
          passed: findings.isEmpty,
          findings: findings,
        );
      }),
    );
  }

  /// Ensures barrel files export only targets matching allowed patterns.
  HeimdallRule<HeimdallSourceFile> barrelFilesShouldOnlyExport({
    String barrelPattern = 'index.dart',
    List<String> allowedExportPatterns = const ['.dart'],
  }) {
    return HeimdallRule(
      descriptionPrefix: 'barrel files',
      selector: (project) => project.files,
      predicate: HeimdallPredicate(
        'barrel files matching $barrelPattern',
        (item, _) => pathMatches(item.relativePath, barrelPattern),
      ),
      condition: HeimdallCondition('only export allowed targets', (item, _) {
        final findings = [
          for (final directive in item.exportDirectives)
            for (final target in directive.targetUris)
              if (!allowedExportPatterns.any(
                (pattern) => pathMatches(target, pattern),
              ))
                HeimdallValidationInfo(
                  filePath: item.absolutePath,
                  line: directive.line,
                  message: 'exports forbidden $target',
                ),
        ];
        return HeimdallFindings(
          subject: item,
          passed: findings.isEmpty,
          findings: findings,
        );
      }),
    );
  }
}

HeimdallRule<HeimdallSourceFile> _emptyPathRule(
  String pathPattern, {
  required String description,
}) {
  final normalizedPattern = normalizePath(pathPattern);
  final childPattern = normalizedPattern.endsWith('/') ? '$normalizedPattern**' : '$normalizedPattern/**';
  return HeimdallRule(
    customDescription: description,
    selector: (project) => project.files,
    predicate: HeimdallPredicate(
      'reside in path $pathPattern',
      (item, _) => pathMatches(item.relativePath, normalizedPattern) || pathMatches(item.relativePath, childPattern),
    ),
    condition: HeimdallCondition('not exist', (item, _) {
      final findings = [
        HeimdallValidationInfo(
          filePath: item.absolutePath,
          message: 'should not exist',
        ),
      ];
      return HeimdallFindings(
        subject: item,
        passed: false,
        findings: findings,
      );
    }),
  );
}

bool _allFiles(HeimdallSourceFile _, HeimdallProject project) => true;

bool _allDeclarations(CompilationUnitMember _, HeimdallProject project) => true;

bool _isIgnoredPublicSignatureDeclaration(
  CompilationUnitMember declaration, {
  required Iterable<String> ignoredPathPatterns,
  required Set<String> ignoredDeclarationNames,
  required Iterable<RegExp> ignoredDeclarationNamePatterns,
}) {
  return ignoredPathPatterns.any(
        (pattern) => _pathMatchesSignatureIgnore(
          declaration.relativePath,
          pattern,
        ),
      ) ||
      ignoredDeclarationNames.contains(declaration.name) ||
      ignoredDeclarationNamePatterns.any(
        (pattern) => pattern.hasMatch(declaration.name),
      );
}

bool _pathMatchesSignatureIgnore(String relativePath, String pattern) {
  final normalizedPattern = normalizePath(pattern);
  if (pathMatches(relativePath, normalizedPattern)) return true;
  if (normalizedPattern.endsWith('.dart')) return false;
  return pathMatches(relativePath, '$normalizedPattern.dart');
}

List<HeimdallValidationInfo> _publicDynamicSignatureFindings(
  CompilationUnitMember declaration,
  HeimdallProject project,
) {
  final findings = <HeimdallValidationInfo>[];
  final rawGenericTypes = _RawGenericTypeResolver(project);
  if (declaration is FunctionDeclaration) {
    _addReturnTypeFinding(
      findings,
      filePath: declaration.sourcePath,
      line: declaration.line,
      type: declaration.returnType,
      name: declaration.name.lexeme,
      project: project,
      origin: declaration,
      rawGenericTypes: rawGenericTypes,
    );
    _addParameterFindings(
      findings,
      project: project,
      origin: declaration,
      rawGenericTypes: rawGenericTypes,
      filePath: declaration.sourcePath,
      lineFor: (node) => declaration.sourceLocationAt(node.offset).line,
      ownerName: declaration.name.lexeme,
      parameters: declaration.functionExpression.parameters?.parameters ?? const [],
    );
  } else if (declaration is TopLevelVariableDeclaration) {
    for (final variable in declaration.variables.variables) {
      if (variable.name.lexeme.startsWith('_')) continue;
      _addVariableTypeFinding(
        findings,
        filePath: declaration.sourcePath,
        line: declaration.sourceLocationAt(variable.offset).line,
        type: declaration.variables.type,
        name: variable.name.lexeme,
        project: project,
        origin: declaration,
        rawGenericTypes: rawGenericTypes,
      );
    }
  } else if (declaration is TypeAlias) {
    _addTypeAliasFindings(
      findings,
      declaration,
      project,
      rawGenericTypes: rawGenericTypes,
    );
  }

  for (final field in declaration.fields) {
    for (final variable in field.fields.variables) {
      if (variable.name.lexeme.startsWith('_')) continue;
      _addVariableTypeFinding(
        findings,
        filePath: field.sourcePath,
        line: field.sourceLocationAt(variable.offset).line,
        type: field.fields.type,
        name: variable.name.lexeme,
        project: project,
        origin: declaration,
        rawGenericTypes: rawGenericTypes,
      );
    }
  }

  for (final method in declaration.methods) {
    if (!method.isPublic) continue;
    final ClassMember methodMember = method;
    _addReturnTypeFinding(
      findings,
      filePath: method.sourcePath,
      line: method.line,
      type: method.returnType,
      name: method.name.lexeme,
      project: project,
      origin: declaration,
      rawGenericTypes: rawGenericTypes,
    );
    _addParameterFindings(
      findings,
      project: project,
      origin: declaration,
      rawGenericTypes: rawGenericTypes,
      filePath: method.sourcePath,
      lineFor: (node) => method.sourceLocationAt(node.offset).line,
      ownerName: method.name.lexeme,
      member: methodMember,
      parameters: methodMember.parameters,
    );
  }

  for (final constructor in declaration.constructors) {
    if (!constructor.isPublic) continue;
    final ClassMember constructorMember = constructor;
    _addParameterFindings(
      findings,
      project: project,
      origin: declaration,
      rawGenericTypes: rawGenericTypes,
      filePath: constructor.sourcePath,
      lineFor: (node) => constructor.sourceLocationAt(node.offset).line,
      ownerName: constructor.name?.lexeme ?? 'new',
      member: constructorMember,
      parameters: constructorMember.parameters,
    );
  }

  return findings;
}

void _addTypeAliasFindings(
  List<HeimdallValidationInfo> findings,
  TypeAlias declaration,
  HeimdallProject project, {
  required _RawGenericTypeResolver rawGenericTypes,
}) {
  switch (declaration) {
    case GenericTypeAlias(:final type):
      if (type is GenericFunctionType) {
        _addFunctionTypeAliasFindings(
          findings,
          declaration,
          project,
          rawGenericTypes: rawGenericTypes,
          returnType: type.returnType,
          parameters: type.parameters.parameters,
        );
      } else {
        _addVariableTypeFinding(
          findings,
          filePath: declaration.sourcePath,
          line: declaration.line,
          type: type,
          name: declaration.name.lexeme,
          project: project,
          origin: declaration,
          rawGenericTypes: rawGenericTypes,
        );
      }
    case FunctionTypeAlias(:final returnType, :final parameters):
      _addFunctionTypeAliasFindings(
        findings,
        declaration,
        project,
        rawGenericTypes: rawGenericTypes,
        returnType: returnType,
        parameters: parameters.parameters,
      );
  }
}

void _addFunctionTypeAliasFindings(
  List<HeimdallValidationInfo> findings,
  TypeAlias declaration,
  HeimdallProject project, {
  required _RawGenericTypeResolver rawGenericTypes,
  required TypeAnnotation? returnType,
  required Iterable<FormalParameter> parameters,
}) {
  _addReturnTypeFinding(
    findings,
    filePath: declaration.sourcePath,
    line: declaration.line,
    type: returnType,
    name: declaration.name.lexeme,
    project: project,
    origin: declaration,
    rawGenericTypes: rawGenericTypes,
  );
  _addParameterFindings(
    findings,
    project: project,
    origin: declaration,
    rawGenericTypes: rawGenericTypes,
    filePath: declaration.sourcePath,
    lineFor: (node) => declaration.sourceLocationAt(node.offset).line,
    ownerName: declaration.name.lexeme,
    parameters: parameters,
  );
}

void _addReturnTypeFinding(
  List<HeimdallValidationInfo> findings, {
  required String filePath,
  required int line,
  required TypeAnnotation? type,
  required String name,
  required HeimdallProject project,
  required CompilationUnitMember origin,
  required _RawGenericTypeResolver rawGenericTypes,
}) {
  if (!_typeContainsPublicDynamic(
    type,
    project: project,
    origin: origin,
    rawGenericTypes: rawGenericTypes,
  )) {
    return;
  }
  findings.add(
    HeimdallValidationInfo(
      filePath: filePath,
      line: line,
      message: '$name has public dynamic return type',
    ),
  );
}

void _addParameterFindings(
  List<HeimdallValidationInfo> findings, {
  required HeimdallProject project,
  required CompilationUnitMember origin,
  required _RawGenericTypeResolver rawGenericTypes,
  required String filePath,
  required int Function(AstNode node) lineFor,
  required String ownerName,
  required Iterable<FormalParameter> parameters,
  ClassMember? member,
}) {
  for (final parameter in parameters) {
    if (!_isDynamicParameter(
      parameter,
      project: project,
      origin: origin,
      rawGenericTypes: rawGenericTypes,
      member: member,
    )) {
      continue;
    }
    findings.add(
      HeimdallValidationInfo(
        filePath: filePath,
        line: lineFor(parameter),
        message: '$ownerName has public dynamic parameter ${parameter.name?.lexeme ?? '<unnamed>'}',
      ),
    );
  }
}

void _addVariableTypeFinding(
  List<HeimdallValidationInfo> findings, {
  required String filePath,
  required int line,
  required TypeAnnotation? type,
  required String name,
  required HeimdallProject project,
  required CompilationUnitMember origin,
  required _RawGenericTypeResolver rawGenericTypes,
}) {
  if (!_typeContainsPublicDynamic(
    type,
    project: project,
    origin: origin,
    rawGenericTypes: rawGenericTypes,
  )) {
    return;
  }
  findings.add(
    HeimdallValidationInfo(
      filePath: filePath,
      line: line,
      message: '$name has public dynamic type',
    ),
  );
}

bool _isDynamicParameter(
  FormalParameter parameter, {
  required HeimdallProject project,
  required CompilationUnitMember origin,
  required _RawGenericTypeResolver rawGenericTypes,
  ClassMember? member,
  Set<String>? visited,
}) {
  final normal = _normalParameter(parameter);
  if (_isWildcardParameter(normal)) return false;
  if (_parameterHasExplicitDynamicSignature(
    normal,
    project: project,
    origin: origin,
    rawGenericTypes: rawGenericTypes,
  )) {
    return true;
  }

  final explicitType = _formalParameterType(normal);
  if (explicitType != null) return false;

  return switch (normal) {
    FieldFormalParameter(:final name) =>
      member != null &&
          _isDynamicFieldFormalParameter(
            member,
            name.lexeme,
            project: project,
            origin: origin,
            rawGenericTypes: rawGenericTypes,
          ),
    SuperFormalParameter(:final name) => _isDynamicSuperFormalParameter(
      member,
      project,
      name.lexeme,
      visited ?? <String>{},
      rawGenericTypes,
    ),
    SimpleFormalParameter() || FunctionTypedFormalParameter() => true,
    _ => true,
  };
}

bool _isWildcardParameter(FormalParameter parameter) => parameter.name?.lexeme == '_';

FormalParameter _normalParameter(FormalParameter parameter) {
  return parameter is DefaultFormalParameter ? parameter.parameter : parameter;
}

TypeAnnotation? _formalParameterType(FormalParameter parameter) {
  return switch (parameter) {
    SimpleFormalParameter(:final type) => type,
    FieldFormalParameter(:final type) => type,
    SuperFormalParameter(:final type) => type,
    FunctionTypedFormalParameter(:final returnType) => returnType,
    _ => null,
  };
}

bool _parameterHasExplicitDynamicSignature(
  FormalParameter parameter, {
  required HeimdallProject project,
  required CompilationUnitMember origin,
  required _RawGenericTypeResolver rawGenericTypes,
}) {
  return switch (parameter) {
    DefaultFormalParameter(:final parameter) => _parameterHasExplicitDynamicSignature(
      parameter,
      project: project,
      origin: origin,
      rawGenericTypes: rawGenericTypes,
    ),
    FunctionTypedFormalParameter(:final returnType, :final parameters) =>
      _typeContainsPublicDynamic(
            returnType,
            project: project,
            origin: origin,
            rawGenericTypes: rawGenericTypes,
          ) ||
          parameters.parameters.any(
            (parameter) => _nestedParameterContainsDynamic(
              parameter,
              project: project,
              origin: origin,
              rawGenericTypes: rawGenericTypes,
            ),
          ),
    SimpleFormalParameter(:final type) || FieldFormalParameter(:final type) || SuperFormalParameter(:final type) => _typeContainsPublicDynamic(
      type,
      project: project,
      origin: origin,
      rawGenericTypes: rawGenericTypes,
    ),
  };
}

bool _nestedParameterContainsDynamic(
  FormalParameter parameter, {
  required HeimdallProject project,
  required CompilationUnitMember origin,
  required _RawGenericTypeResolver rawGenericTypes,
}) {
  final normal = _normalParameter(parameter);
  if (_isWildcardParameter(normal)) return false;
  if (_parameterHasExplicitDynamicSignature(
    normal,
    project: project,
    origin: origin,
    rawGenericTypes: rawGenericTypes,
  )) {
    return true;
  }
  return _formalParameterType(normal) == null;
}

bool _isDynamicFieldFormalParameter(
  ClassMember member,
  String fieldName, {
  required HeimdallProject project,
  required CompilationUnitMember origin,
  required _RawGenericTypeResolver rawGenericTypes,
}) {
  for (final field in member.owner.fields) {
    if (field.fields.variables.any((variable) => variable.name.lexeme == fieldName)) {
      return _typeContainsPublicDynamic(
        field.fields.type,
        project: project,
        origin: origin,
        rawGenericTypes: rawGenericTypes,
      );
    }
  }
  return false;
}

bool _isDynamicSuperFormalParameter(
  ClassMember? member,
  HeimdallProject project,
  String parameterName,
  Set<String> visited,
  _RawGenericTypeResolver rawGenericTypes,
) {
  final owner = member?.owner;
  if (owner is! ClassDeclaration || member is! ConstructorDeclaration) {
    return false;
  }

  final superclassName = owner.extendsClause?.superclass.name.lexeme;
  if (superclassName == null) return false;

  final superclass = declarationNamedFrom(owner, project, superclassName);
  if (superclass == null) return false;

  final constructorName = _superConstructorName(member);
  final targetConstructor = _constructorNamed(superclass, constructorName);
  if (targetConstructor == null) return false;

  final key = '${superclass.sourcePath}:${superclass.name}:$constructorName:$parameterName';
  if (!visited.add(key)) return false;

  final ClassMember targetConstructorMember = targetConstructor;
  for (final parameter in targetConstructorMember.parameters) {
    if (parameter.name?.lexeme != parameterName) continue;
    return _isDynamicParameter(
      parameter,
      project: project,
      origin: superclass,
      rawGenericTypes: rawGenericTypes,
      member: targetConstructorMember,
      visited: visited,
    );
  }
  return false;
}

ConstructorDeclaration? _constructorNamed(
  CompilationUnitMember declaration,
  String constructorName,
) {
  for (final constructor in declaration.constructors) {
    if ((constructor.name?.lexeme ?? '') == constructorName) return constructor;
  }
  return null;
}

String _superConstructorName(ConstructorDeclaration constructor) {
  for (final initializer in constructor.initializers) {
    if (initializer is SuperConstructorInvocation) {
      return initializer.constructorName?.name ?? '';
    }
  }
  return '';
}

bool _typeContainsPublicDynamic(
  TypeAnnotation? type, {
  required HeimdallProject project,
  required CompilationUnitMember origin,
  required _RawGenericTypeResolver rawGenericTypes,
}) {
  return switch (type) {
    NamedType(:final typeArguments) =>
      typeAnnotationName(type) == 'dynamic' ||
          _isRawGenericType(
            type,
            origin: origin,
            rawGenericTypes: rawGenericTypes,
          ) ||
          (!_isDynamicAllowedCollectionType(type) &&
              (typeArguments?.arguments.any(
                    (argument) => _typeContainsPublicDynamic(
                      argument,
                      project: project,
                      origin: origin,
                      rawGenericTypes: rawGenericTypes,
                    ),
                  ) ??
                  false)),
    GenericFunctionType(:final returnType, :final parameters) =>
      _typeContainsPublicDynamic(
            returnType,
            project: project,
            origin: origin,
            rawGenericTypes: rawGenericTypes,
          ) ||
          parameters.parameters.any(
            (parameter) => _nestedParameterContainsDynamic(
              parameter,
              project: project,
              origin: origin,
              rawGenericTypes: rawGenericTypes,
            ),
          ),
    _ => false,
  };
}

bool _isRawGenericType(
  NamedType type, {
  required CompilationUnitMember origin,
  required _RawGenericTypeResolver rawGenericTypes,
}) {
  return type.typeArguments == null &&
      rawGenericTypes.containsReference(
        origin,
        namedTypeReferenceName(type),
      );
}

bool _isDynamicAllowedCollectionType(NamedType type) {
  return const {'List', 'Set', 'Iterable', 'Map'}.contains(type.name.lexeme) && type.importPrefix == null;
}

const _knownExternalRawGenericTypeNames = {'Bloc', 'Cubit', 'Future', 'Stream'};

/// Resolves raw generic references while one public declaration is inspected.
///
/// The indexes only live for the current rule evaluation; they are not kept by
/// the project and therefore cannot become stale between checks.
final class _RawGenericTypeResolver {
  _RawGenericTypeResolver(this._project);

  final HeimdallProject _project;
  final Map<({String sourcePath, String? importPrefix}), _VisibleTypeReferenceIndex> _indexes = {};

  bool containsReference(
    CompilationUnitMember origin,
    String reference, [
    Set<String>? visited,
  ]) {
    final checked = visited ?? <String>{};
    final key = '${origin.sourcePath}:$reference';
    if (!checked.add(key)) return false;

    final separator = reference.indexOf('.');
    final prefix = separator < 0 ? null : reference.substring(0, separator);
    final name = separator < 0 ? reference : reference.substring(separator + 1);
    if (prefix == null && _knownExternalRawGenericTypeNames.contains(name)) {
      return true;
    }

    final index = _indexFor(origin, prefix);
    final alias = index.aliases[name];
    if (alias != null) {
      if (_declarationHasTypeParameters(alias)) return true;
      final target = _typeAliasTargetReference(alias);
      return target != null && containsReference(alias, target, checked);
    }

    final declaration = index.declarations[name];
    return declaration != null && _declarationHasTypeParameters(declaration);
  }

  _VisibleTypeReferenceIndex _indexFor(
    CompilationUnitMember origin,
    String? importPrefix,
  ) {
    final key = (
      sourcePath: origin.sourcePath,
      importPrefix: importPrefix,
    );
    return _indexes.putIfAbsent(
      key,
      () => _VisibleTypeReferenceIndex(
        visibleTypeReferenceDeclarationsFrom(
          origin,
          _project,
          importPrefix: importPrefix,
        ),
      ),
    );
  }
}

final class _VisibleTypeReferenceIndex {
  _VisibleTypeReferenceIndex(Iterable<CompilationUnitMember> declarations) {
    for (final declaration in declarations) {
      if (declaration case final TypeAlias alias) {
        aliases.putIfAbsent(alias.name.lexeme, () => alias);
      } else {
        this.declarations.putIfAbsent(declaration.name, () => declaration);
      }
    }
  }

  final Map<String, TypeAlias> aliases = {};
  final Map<String, CompilationUnitMember> declarations = {};
}

String? _typeAliasTargetReference(TypeAlias alias) {
  if (alias case GenericTypeAlias(:final NamedType type)) {
    return namedTypeReferenceName(type);
  }
  return null;
}

bool _declarationHasTypeParameters(CompilationUnitMember declaration) {
  return switch (declaration) {
    ClassDeclaration(:final namePart) => _classNamePartHasTypeParameters(namePart),
    EnumDeclaration(:final namePart) => _classNamePartHasTypeParameters(namePart),
    MixinDeclaration(:final typeParameters) => typeParameters?.typeParameters.isNotEmpty ?? false,
    GenericTypeAlias(:final typeParameters) => typeParameters?.typeParameters.isNotEmpty ?? false,
    FunctionTypeAlias(:final typeParameters) => typeParameters?.typeParameters.isNotEmpty ?? false,
    _ => false,
  };
}

bool _classNamePartHasTypeParameters(ClassNamePart namePart) {
  final typeParameters = namePart.childEntities.whereType<TypeParameterList>().firstOrNull;
  return typeParameters?.typeParameters.isNotEmpty ?? false;
}
