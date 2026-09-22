import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/file_features/helpers/source_file_location.dart';

/// Predicate-side DSL for documentation comment regex rules.
extension FileContentStructurePredicateRules on FilePredicateBuilder {
  /// Selects files with a directive or top-level declaration documentation comment matching [pattern].
  FilePredicateBuilder haveDocumentationCommentMatching(RegExp pattern) {
    return satisfy(_fileHasDocumentationCommentMatching(pattern));
  }

  /// Selects files with no directive or top-level declaration documentation comment matching [pattern].
  FilePredicateBuilder haveNoDocumentationCommentMatching(RegExp pattern) {
    return satisfy(_fileDoesNotHaveDocumentationCommentMatching(pattern));
  }

  /// Selects files with a matching documentation comment for every pattern in [patterns] (possibly different comments).
  FilePredicateBuilder haveDocumentationCommentMatchingAllOf(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.allOf(
        patternList.map(_fileHasDocumentationCommentMatching),
        description: 'have documentation comment matching all of ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects files with a documentation comment matching at least one pattern in [patterns].
  FilePredicateBuilder haveDocumentationCommentMatchingAnyOf(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.anyOf(
        patternList.map(_fileHasDocumentationCommentMatching),
        description: 'have documentation comment matching any of ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects files with no documentation comment matching any of [patterns].
  FilePredicateBuilder haveDocumentationCommentMatchingNoneOf(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.noneOf(
        patternList.map(_fileHasDocumentationCommentMatching),
        description: 'have documentation comment matching none of ${patternList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for documentation comment regex rules.
extension FileContentStructureShouldRules on FileShouldBuilder {
  /// Requires matching files to have a directive or top-level declaration documentation comment matching [pattern].
  HeimdallRule<HeimdallSourceFile> haveDocumentationCommentMatching(
    RegExp pattern,
  ) {
    return satisfy(_fileShouldHaveDocumentationCommentMatching(pattern));
  }

  /// Requires matching files to have no documentation comment matching [pattern].
  HeimdallRule<HeimdallSourceFile> haveNoDocumentationCommentMatching(
    RegExp pattern,
  ) {
    return satisfy(_fileShouldNotHaveDocumentationCommentMatching(pattern));
  }

  /// Requires matching files to have a matching documentation comment for every pattern (possibly different comments).
  HeimdallRule<HeimdallSourceFile> haveDocumentationCommentMatchingAllOf(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.allOf(
        patternList.map(_fileShouldHaveDocumentationCommentMatching),
        description: 'have documentation comment matching all of ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to have a documentation comment matching at least one pattern in [patterns].
  HeimdallRule<HeimdallSourceFile> haveDocumentationCommentMatchingAnyOf(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.anyOf(
        patternList.map(_fileShouldHaveDocumentationCommentMatching),
        description: 'have documentation comment matching any of ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to have no documentation comment matching any of [patterns].
  HeimdallRule<HeimdallSourceFile> haveDocumentationCommentMatchingNoneOf(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.noneOf(
        patternList.map(_fileShouldHaveDocumentationCommentMatching),
        description: 'have documentation comment matching none of ${patternList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<HeimdallSourceFile> _fileHasDocumentationCommentMatching(
  RegExp pattern,
) {
  return HeimdallPredicate(
    'have documentation comment matching $pattern',
    (item, _) => _documentationComments(item).any(
      (comment) => comment.contains(pattern),
    ),
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldHaveDocumentationCommentMatching(RegExp pattern) {
  return HeimdallCondition('have documentation comment matching $pattern', (
    item,
    _,
  ) {
    final findings = _documentationComments(item).any((comment) => comment.contains(pattern))
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              message: 'does not have a documentation comment matching ${pattern.pattern}',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

Iterable<String> _documentationComments(HeimdallSourceFile file) sync* {
  final nodes = [...file.directives, ...file.declarations]
    ..sort(
      (a, b) => a.offset.compareTo(b.offset),
    );
  for (final node in nodes) {
    final comment = node.documentationComment;
    if (comment == null) continue;
    yield comment.tokens.map((token) => token.lexeme).join('\n');
  }
}

HeimdallPredicate<HeimdallSourceFile> _fileDoesNotHaveDocumentationCommentMatching(RegExp pattern) {
  return HeimdallPredicate(
    'not have documentation comment matching $pattern',
    (item, _) => !_documentationComments(item).any(
      (comment) => comment.contains(pattern),
    ),
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldNotHaveDocumentationCommentMatching(RegExp pattern) {
  return HeimdallCondition('not have documentation comment matching $pattern', (
    item,
    _,
  ) {
    final findings = <HeimdallValidationInfo>[];
    final nodes = [...item.directives, ...item.declarations]..sort((a, b) => a.offset.compareTo(b.offset));
    for (final node in nodes) {
      final comment = node.documentationComment;
      if (comment == null) continue;
      final source = comment.tokens.map((token) => token.lexeme).join('\n');
      if (!source.contains(pattern)) continue;
      findings.add(
        fileNodeFinding(
          item,
          node,
          'has forbidden documentation comment matching ${pattern.pattern}',
          offset: comment.offset,
        ),
      );
    }
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
