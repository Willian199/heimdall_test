import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_dependency_queries.dart';
import 'package:test/test.dart';

const _fixtureRoot = 'test/architecture_fixtures/layer_issues';

HeimdallProject _import(String fixture) => const HeimdallFileImporter(useCache: false).importPath('$_fixtureRoot/$fixture/lib');

HeimdallLayers _layers() => Heimdall.layers().layer('UI').definedBy(['ui/**']).layer('Domain').definedBy(['domain/**']);

void main() {
  tearDown(HeimdallFileImporter.clearCache);

  test('declaration expression slices reuse the file index and isolate siblings', () {
    final project = _import('independent_sources');
    final file = project.fileByRelativePath('ui/profile.dart')!;
    final profile = file.declarations.first;
    final header = file.declarations.last;
    // Request a slice before the flattened list: both access orders must work.
    final expressions = file.expressionsInDeclaration(profile);
    expect(expressions, isNotEmpty);
    expect(file.expressionsInDeclaration(profile), same(expressions));
    expect(file.expressionsInDeclaration(header), isNotEmpty);
    expect(expressions.every((expression) => expression.offset >= profile.offset && expression.end <= profile.end), isTrue);
    expect(file.expressionsInDeclaration(header).any(expressions.contains), isFalse);
    expect(file.declarations.expand(file.expressionsInDeclaration), orderedEquals(file.expressions));
    expect(expressions.clear, throwsUnsupportedError);
    expect(file.expressions.clear, throwsUnsupportedError);
  });

  test('the warmed expression index retains nested function calls and annotations', () {
    final nested = _import('review_nested_function').fileByRelativePath('ui/profile.dart')!;
    final flat = nested.expressions;
    final expressions = nested.expressionsInDeclaration(nested.declarations.single);
    expect(expressions.map((expression) => expression.toSource()), contains('answer()'));
    expect(flat, orderedEquals(expressions));
    expect(nested.expressions, same(flat));

    final annotated = _import('function_annotation').fileByRelativePath('ui/profile.dart')!;
    final function = annotated.topLevelFunctions.single;
    expect(annotated.expressionsInDeclaration(function).whereType<SimpleIdentifier>().map((identifier) => identifier.name), contains('User'));
    expect(annotated.expressionsInDeclaration(function), orderedEquals(annotated.expressions));
  });

  test('a file expression slice cannot expose another file declaration', () {
    final project = _import('multiple_types');
    final ui = project.fileByRelativePath('ui/profile.dart')!;
    final domain = project.fileByRelativePath('domain/model.dart')!;
    expect(ui.expressionsInDeclaration(domain.declarations.first), isEmpty);
    expect(ui.expressionsInDeclaration(ui.declarations.single), isNotEmpty);
  });

  test('type and value dependency results are immutable and reused separately', () {
    final project = _import('function_target');
    final profile = project.fileByRelativePath('ui/profile.dart')!.declarations.single;
    final types = declarationDependenciesFrom(profile, project);
    final all = allDeclarationDependenciesFrom(profile, project);
    expect(types, isEmpty);
    expect(all, hasLength(1));
    expect(all.single.target.name, 'answer');
    expect(declarationDependenciesFrom(profile, project), same(types));
    expect(allDeclarationDependenciesFrom(profile, project), same(all));
    expect(types.clear, throwsUnsupportedError);
    expect(all.clear, throwsUnsupportedError);
    expect(project.declarationDependencies, same(project.declarationDependencies));
  });

  test('declarations in one file share immutable library scope information', () {
    final project = _import('independent_sources');
    final file = project.fileByRelativePath('ui/profile.dart')!;
    final first = project.libraryScopes.scopeOf(file.declarations.first);
    final second = project.libraryScopes.scopeOf(file.declarations.last);
    expect(first, same(second));
    expect(first.typeNames, unorderedEquals(['Profile', 'Header']));
    expect(first.names, same(second.names));
    expect(first.files.clear, throwsUnsupportedError);
    expect(first.dependencies.clear, throwsUnsupportedError);
    expect(first.typeNames.clear, throwsUnsupportedError);
    expect(first.valueNames.clear, throwsUnsupportedError);
    expect(first.names.clear, throwsUnsupportedError);
  });

  test('cached part ownership keeps independent libraries separate', () {
    final project = _import('two_owners');
    final header = project.fileByRelativePath('ui/header.dart')!.declarations.single;
    final footer = project.fileByRelativePath('ui/footer.dart')!.declarations.single;
    final headerScope = project.libraryScopes.scopeOf(header);
    final footerScope = project.libraryScopes.scopeOf(footer);
    expect(headerScope.files.map((file) => file.relativePath), unorderedEquals(['ui/header.dart', 'ui/profile.dart']));
    expect(footerScope.files.map((file) => file.relativePath), unorderedEquals(['ui/footer.dart', 'ui/other.dart']));
    expect(project.libraryScopes.scopeOf(header), same(headerScope));
    expect(headerScope.dependencies.whereType<ImportDirective>().single.originPath, project.fileByRelativePath('ui/profile.dart')!.absolutePath);
    expect(footerScope.dependencies.whereType<ImportDirective>().single.originPath, project.fileByRelativePath('ui/other.dart')!.absolutePath);
  });

  test('namespace caches preserve individual visibility and resolved branches', () {
    final project = _import('target_variable_show');
    final file = project.fileByRelativePath('ui/profile.dart')!;
    final directive = file.importDirectives.single;
    final target = directive.targetFiles.single;
    final index = project.declarationNamespace;
    final visible = index.visibleSymbols(directive, target);
    expect(visible.map((symbol) => symbol.name), ['answer']);
    expect(index.exportedSymbols(target).map((symbol) => symbol.name), unorderedEquals(['other', 'answer']));
    expect(index.visibleSymbols(directive, target), same(visible));
    expect(index.declaredSymbols(target), same(index.declaredSymbols(target)));
    expect(visible.clear, throwsUnsupportedError);

    final conditional = _import('conditional_types');
    final import = conditional.fileByRelativePath('ui/profile.dart')!.importDirectives.single;
    final primary = conditional.declarationNamespace.visibleSymbols(import, import.resolvedTargets.first.file);
    final alternative = conditional.declarationNamespace.visibleSymbols(import, import.resolvedTargets.last.file);
    expect(primary.every((symbol) => symbol.declaration.relativePath == 'domain/model.dart'), isTrue);
    expect(alternative.every((symbol) => symbol.declaration.relativePath == 'domain/web.dart'), isTrue);
    expect(primary, isNot(same(alternative)));
  });

  test('exported and visible type projections reuse project caches', () {
    final project = _import('barrel_types');
    final directive = project.fileByRelativePath('ui/profile.dart')!.importDirectives.single;
    final target = directive.targetFiles.single;
    final exported = project.exportedTypeDeclarationsOf(target);
    final branch = project.visibleTypeDeclarationsThroughTarget(directive, target);
    final visible = project.visibleTypeDeclarationsThrough(directive);
    expect(exported.map((declaration) => declaration.name), unorderedEquals(['User', 'Address']));
    expect(project.exportedTypeDeclarationsOf(target), same(exported));
    expect(project.visibleTypeDeclarationsThroughTarget(directive, target), same(branch));
    expect(project.visibleTypeDeclarationsThrough(directive), same(visible));
    expect(exported.clear, throwsUnsupportedError);
    expect(branch.clear, throwsUnsupportedError);
    expect(visible.clear, throwsUnsupportedError);
  });

  test('import cache clearing and useCache false create independent derived caches', () {
    HeimdallFileImporter.clearCache();
    const importer = HeimdallFileImporter();
    const root = '$_fixtureRoot/mixed_crossings/lib';
    final first = importer.importPath(root);
    final originalItem = first.fileByRelativePath('ui/profile.dart')!.declarations.first;
    final edges = allDeclarationDependenciesFrom(originalItem, first);
    final reused = importer.importPath(root);
    expect(reused, same(first));
    expect(allDeclarationDependenciesFrom(originalItem, reused), same(edges));

    HeimdallFileImporter.clearCache();
    final fresh = importer.importPath(root);
    final uncached = const HeimdallFileImporter(useCache: false).importPath(root);
    for (final snapshot in [fresh, uncached]) {
      final item = snapshot.fileByRelativePath('ui/profile.dart')!.declarations.first;
      final newEdges = allDeclarationDependenciesFrom(item, snapshot);
      expect(snapshot, isNot(same(first)));
      expect(snapshot.declarationNamespace, isNot(same(first.declarationNamespace)));
      expect(snapshot.libraryScopes, isNot(same(first.libraryScopes)));
      expect(snapshot.declarationDependencies, isNot(same(first.declarationDependencies)));
      expect(newEdges, isNot(same(edges)));
      expect(newEdges.single.target, isNot(same(edges.single.target)));
      expect(newEdges.single.target.name, edges.single.target.name);
    }
    expect(allDeclarationDependenciesFrom(originalItem, first), same(edges));
  });

  test('warm dependency caches do not retain the constraints of a previous rule', () {
    final project = _import('mixed_crossings');
    final forbidden = _layers().whereLayer('UI').mayNotAccessAnyLayer().asRule();
    final allowed = _layers().whereLayer('UI').mayOnlyAccessLayers(['Domain']).asRule();
    expect(forbidden.check(project).findings, hasLength(3));
    expect(allowed.check(project).findings, isEmpty);
    expect(forbidden.check(project).findings, hasLength(3));
  });
}
