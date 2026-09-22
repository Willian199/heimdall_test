import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  group('Member rule DSL contract', () {
    test('keeps predicate and should builder member methods in sync', () {
      final project = const HeimdallFileImporter(useCache: false).importPath();
      final predicateMethods = _publicBuilderMethodNames(
        project,
        relativePath: 'src/core/member_rules/member_predicate_builder.dart',
        className: 'MemberPredicateBuilder',
      );
      final shouldMethods = _publicBuilderMethodNames(
        project,
        relativePath: 'src/core/member_rules/member_should_builder.dart',
        className: 'MemberShouldBuilder',
      );

      final predicateContractNames = predicateMethods.map(_memberRuleMethodKey).whereType<String>().toSet();
      final shouldContractNames = shouldMethods.map(_memberRuleMethodKey).whereType<String>().toSet();

      expect(
        predicateContractNames.difference(shouldContractNames),
        isEmpty,
        reason: 'Every public MemberPredicateBuilder member rule method must have a matching MemberShouldBuilder method.',
      );
      expect(
        shouldContractNames.difference(predicateContractNames),
        isEmpty,
        reason: 'Every public MemberShouldBuilder member rule method must have a matching MemberPredicateBuilder method.',
      );
    });

    test('keeps two-sided member rule feature methods in sync', () {
      final project = const HeimdallFileImporter(useCache: false).importPath();
      final predicateMethods = _publicTwoSidedFeatureMethodNames(
        project,
        builderName: 'MemberPredicateBuilder',
      );
      final shouldMethods = _publicTwoSidedFeatureMethodNames(
        project,
        builderName: 'MemberShouldBuilder',
      );

      final predicateContractNames = predicateMethods.map(_memberRuleMethodKey).whereType<String>().toSet();
      final shouldContractNames = shouldMethods.map(_memberRuleMethodKey).whereType<String>().toSet();

      expect(
        predicateContractNames.difference(shouldContractNames),
        isEmpty,
        reason: 'Every two-sided member predicate feature method must have a matching should feature method.',
      );
      expect(
        shouldContractNames.difference(predicateContractNames),
        isEmpty,
        reason: 'Every two-sided member should feature method must have a matching predicate feature method.',
      );
    });
  });
}

Set<String> _publicBuilderMethodNames(
  HeimdallProject project, {
  required String relativePath,
  required String className,
}) {
  final file = project.fileByRelativePath(relativePath);
  if (file == null) {
    throw StateError('Could not find $relativePath in imported project.');
  }

  final declaration = file.declarations
      .whereType<ClassDeclaration>()
      .where((declaration) => declaration.namePart.typeName.lexeme == className)
      .single;

  final members = switch (declaration.body) {
    BlockClassBody(:final members) => members,
    _ => const <ClassMember>[],
  };

  return members.whereType<MethodDeclaration>().map((method) => method.name.lexeme).where((name) => !name.startsWith('_')).toSet();
}

Set<String> _publicTwoSidedFeatureMethodNames(
  HeimdallProject project, {
  required String builderName,
}) {
  return project.files
      .where(
        (file) => pathMatches(
          file.relativePath,
          'src/features/member_features/features/*.dart',
        ),
      )
      .where(
        (file) => _extensionsOn(file, 'MemberPredicateBuilder').isNotEmpty && _extensionsOn(file, 'MemberShouldBuilder').isNotEmpty,
      )
      .expand((file) => _extensionsOn(file, builderName))
      .expand((extension) => extension.body.members)
      .whereType<MethodDeclaration>()
      .map((method) => method.name.lexeme)
      .where((name) => !name.startsWith('_'))
      .toSet();
}

Iterable<ExtensionDeclaration> _extensionsOn(
  HeimdallSourceFile file,
  String builderName,
) {
  return file.declarations.whereType<ExtensionDeclaration>().where(
    (declaration) => declaration.onClause?.extendedType.toSource() == builderName,
  );
}

String? _memberRuleMethodKey(String methodName) {
  const infrastructureMethods = {
    'and',
    'or',
    'should',
    'andShould',
    'orShould',
    'not',
    'satisfy',
    'allowEmpty',
    'failOnEmpty',
  };

  if (infrastructureMethods.contains(methodName)) return null;
  return _stripFluentPrefix(methodName).toLowerCase();
}

String _stripFluentPrefix(String methodName) {
  if (methodName.startsWith('not') && methodName.length > 3 && _isUppercase(methodName.codeUnitAt(3))) {
    return 'not${_stripFluentPrefix(_lowercaseFirst(methodName.substring(3)))}';
  }

  for (final prefix in ['are', 'be']) {
    if (methodName.startsWith(prefix) && methodName.length > prefix.length && _isUppercase(methodName.codeUnitAt(prefix.length))) {
      return methodName.substring(prefix.length);
    }
  }
  return methodName;
}

String _lowercaseFirst(String value) {
  return value.isEmpty ? value : '${value.substring(0, 1).toLowerCase()}${value.substring(1)}';
}

bool _isUppercase(int codeUnit) {
  return codeUnit >= 65 && codeUnit <= 90;
}
