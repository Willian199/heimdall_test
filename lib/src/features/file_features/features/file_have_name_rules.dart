import 'package:heimdall_test/heimdall_test.dart';
import 'package:path/path.dart' as p;

/// Predicate-side DSL for exact file name rules.
extension FileHaveNamePredicateRules on FilePredicateBuilder {
  /// Selects files with exactly [name].
  FilePredicateBuilder haveName(String name) => satisfy(_fileHasName(name));

  /// Selects files without exactly [name].
  FilePredicateBuilder noHaveName(String name) => satisfy(_fileDoesNotHaveName(name));

  /// Selects files with any name in [names].
  FilePredicateBuilder haveNameAny(Iterable<String> names) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallPredicate.anyOf(
        nameList.map(_fileHasName),
        description: 'have any name ${nameList.join(', ')}',
      ),
    );
  }

  /// Selects files with every name in [names].
  FilePredicateBuilder haveNameAll(Iterable<String> names) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallPredicate.allOf(
        nameList.map(_fileHasName),
        description: 'have all names ${nameList.join(', ')}',
      ),
    );
  }

  /// Selects files with none of [names].
  FilePredicateBuilder haveNameNone(Iterable<String> names) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallPredicate.noneOf(
        nameList.map(_fileHasName),
        description: 'have none of names ${nameList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for exact file name rules.
extension FileHaveNameShouldRules on FileShouldBuilder {
  /// Requires matching file names to equal [name].
  HeimdallRule<HeimdallSourceFile> haveName(String name) {
    return satisfy(_fileShouldHaveName(name));
  }

  /// Requires matching file names to not equal [name].
  HeimdallRule<HeimdallSourceFile> noHaveName(String name) {
    return satisfy(_fileShouldNotHaveName(name));
  }

  /// Requires matching file names to equal at least one name in [names].
  HeimdallRule<HeimdallSourceFile> haveNameAny(Iterable<String> names) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallCondition.anyOf(
        nameList.map(_fileShouldHaveName),
        description: 'have any name ${nameList.join(', ')}',
      ),
    );
  }

  /// Requires matching file names to equal every name in [names].
  HeimdallRule<HeimdallSourceFile> haveNameAll(Iterable<String> names) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallCondition.allOf(
        nameList.map(_fileShouldHaveName),
        description: 'have all names ${nameList.join(', ')}',
      ),
    );
  }

  /// Requires matching file names to equal none of [names].
  HeimdallRule<HeimdallSourceFile> haveNameNone(Iterable<String> names) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallCondition.noneOf(
        nameList.map(_fileShouldHaveName),
        description: 'have none of names ${nameList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<HeimdallSourceFile> _fileHasName(String name) {
  return HeimdallPredicate(
    'have name $name',
    (item, _) => p.basename(item.relativePath) == name,
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldHaveName(String name) {
  return HeimdallCondition('have name $name', (item, _) {
    final findings = p.basename(item.relativePath) == name
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              message: 'should have name $name',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallPredicate<HeimdallSourceFile> _fileDoesNotHaveName(String name) {
  return HeimdallPredicate(
    'not have name $name',
    (item, _) => p.basename(item.relativePath) != name,
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldNotHaveName(String name) {
  return HeimdallCondition('not have name $name', (item, _) {
    final findings = p.basename(item.relativePath) != name
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              line: 1,
              column: 1,
              message: 'has forbidden name $name',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
