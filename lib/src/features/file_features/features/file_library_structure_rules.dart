import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for named library directive rules.
extension FileLibraryStructurePredicateRules on FilePredicateBuilder {
  /// Selects files that declare a `library` directive named [name].
  FilePredicateBuilder haveLibraryDirectiveNamed(String name) {
    return satisfy(_fileHasLibraryDirectiveNamed(name));
  }

  /// Selects files that do not declare a `library` directive named [name].
  FilePredicateBuilder noHaveLibraryDirectiveNamed(String name) {
    return satisfy(
      HeimdallPredicate(
        'not have library directive named $name',
        (item, _) => _libraryDirectiveName(item) != name,
      ),
    );
  }

  /// Selects files that declare every library directive name in [names].
  FilePredicateBuilder haveAllLibraryDirectivesNamed(Iterable<String> names) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallPredicate.allOf(
        nameList.map(_fileHasLibraryDirectiveNamed),
        description: 'have all library directives named ${nameList.join(', ')}',
      ),
    );
  }

  /// Selects files that declare at least one library directive name in [names].
  FilePredicateBuilder haveAnyLibraryDirectiveNamed(Iterable<String> names) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallPredicate.anyOf(
        nameList.map(_fileHasLibraryDirectiveNamed),
        description: 'have any library directive named ${nameList.join(', ')}',
      ),
    );
  }

  /// Selects files that declare none of the library directive names in [names].
  FilePredicateBuilder haveNoLibraryDirectivesNamed(Iterable<String> names) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallPredicate.noneOf(
        nameList.map(_fileHasLibraryDirectiveNamed),
        description: 'have no library directives named ${nameList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for named library directive rules.
extension FileLibraryStructureShouldRules on FileShouldBuilder {
  /// Requires matching files to declare a `library` directive named [name].
  HeimdallRule<HeimdallSourceFile> haveLibraryDirectiveNamed(String name) {
    return satisfy(_fileShouldHaveLibraryDirectiveNamed(name));
  }

  /// Requires matching files to not declare a `library` directive named [name].
  HeimdallRule<HeimdallSourceFile> noHaveLibraryDirectiveNamed(String name) {
    return satisfy(
      HeimdallCondition('not have library directive named $name', (
        item,
        _,
      ) {
        final directive = item.libraryDirective;
        final findings = _libraryDirectiveName(item) != name || directive == null
            ? const <HeimdallValidationInfo>[]
            : [
                HeimdallValidationInfo(
                  filePath: item.absolutePath,
                  line: directive.line,
                  column: 1,
                  message: 'declares forbidden library $name',
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

  /// Requires matching files to declare every library directive name in [names].
  HeimdallRule<HeimdallSourceFile> haveAllLibraryDirectivesNamed(
    Iterable<String> names,
  ) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallCondition.allOf(
        nameList.map(_fileShouldHaveLibraryDirectiveNamed),
        description: 'have all library directives named ${nameList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to declare at least one library directive name in [names].
  HeimdallRule<HeimdallSourceFile> haveAnyLibraryDirectiveNamed(
    Iterable<String> names,
  ) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallCondition.anyOf(
        nameList.map(_fileShouldHaveLibraryDirectiveNamed),
        description: 'have any library directive named ${nameList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to declare none of the library directive names in [names].
  HeimdallRule<HeimdallSourceFile> haveNoLibraryDirectivesNamed(
    Iterable<String> names,
  ) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallCondition.noneOf(
        nameList.map(_fileShouldHaveLibraryDirectiveNamed),
        description: 'have no library directives named ${nameList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<HeimdallSourceFile> _fileHasLibraryDirectiveNamed(
  String name,
) {
  return HeimdallPredicate(
    'have library directive named $name',
    (item, _) => _libraryDirectiveName(item) == name,
  );
}

String? _libraryDirectiveName(HeimdallSourceFile item) {
  final name = item.libraryDirective?.name;
  return name?.components.map((component) => component.name).join('.');
}

HeimdallCondition<HeimdallSourceFile> _fileShouldHaveLibraryDirectiveNamed(
  String name,
) {
  return HeimdallCondition('have library directive named $name', (item, _) {
    final findings = _libraryDirectiveName(item) == name
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              message: 'does not declare library $name',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
