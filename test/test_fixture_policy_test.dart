import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  test('tests and helpers access fixed sources only through the package', () {
    final project = const HeimdallFileImporter(useCache: false).importPath('test');
    Heimdall.files()
        .that()
        .haveNameDifferentFrom('class_rule_test.dart')
        .and()
        .haveNameDifferentFrom('publication_regression_test.dart')
        .should()
        .notImportUriMatching(RegExp('^(dart:io|package:(file|path|analyzer)/)'))
        .check(project)
        .assertNoFindings();

    // Inspect AST calls so strings used to test forbidden source are harmless.
    const forbiddenCalls = {
      'File',
      'Directory',
      'Link',
      'Process',
      'HeimdallSourceFile',
      'HeimdallProject',
      'FreezingHeimdallRule',
      'freeze',
      'parseString',
      'parseFile',
      'readAsString',
      'readAsStringSync',
      'readAsBytes',
      'readAsBytesSync',
      'readAsLines',
      'readAsLinesSync',
      'writeAsString',
      'writeAsStringSync',
      'writeAsBytes',
      'writeAsBytesSync',
      'createTemp',
      'createTempSync',
      'create',
      'createSync',
      'delete',
      'deleteSync',
      'setLastModified',
      'setLastModifiedSync',
    };
    for (final file in project.files) {
      final roots = <AstNode>[...file.directives, ...file.declarations];
      for (final node in roots.expand((root) => _nodes(root, file.relativePath))) {
        final name = switch (node) {
          MethodInvocation(:final methodName) => methodName.name,
          InstanceCreationExpression(:final constructorName) => constructorName.type.name.lexeme,
          _ => null,
        };
        expect(forbiddenCalls.contains(name), isFalse, reason: '${file.relativePath}: ${node.toSource()}');
      }
    }
  });
}

Iterable<AstNode> _nodes(AstNode root, String relativePath) sync* {
  // Only these existing persistence tests may create or inspect JSON baselines.
  const jsonTests = {
    'class_rule_test.dart': {
      'freezes known findings and ignore patterns hide matches',
      'reports findings missing from the freeze store',
      'freeze creates an empty baseline before later violations',
    },
    'publication_regression_test.dart': {
      'freeze survives relocation and import-root changes while reporting new findings',
    },
  };
  if (root is MethodInvocation && root.methodName.name == 'test') {
    final name = root.argumentList.arguments.firstOrNull;
    if (name is SimpleStringLiteral && (jsonTests[relativePath]?.contains(name.value) ?? false)) return;
  }
  yield root;
  for (final child in root.childEntities.whereType<AstNode>()) {
    yield* _nodes(child, relativePath);
  }
}
