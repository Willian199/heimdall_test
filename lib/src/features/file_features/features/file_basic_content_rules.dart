import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/file_features/helpers/source_file_location.dart';

/// Predicate-side DSL for basic source-file content rules.
extension FileBasicContentPredicateRules on FilePredicateBuilder {
  /// Selects files that have at least one Dart documentation comment.
  FilePredicateBuilder haveDocumentationComment() {
    return satisfy(_fileHasDocumentationComment());
  }

  /// Selects files that have no Dart documentation comments.
  FilePredicateBuilder noHaveDocumentationComment() {
    return satisfy(_fileHasNoDocumentationComment());
  }
}

/// Condition-side DSL for basic source-file content rules.
extension FileBasicContentShouldRules on FileShouldBuilder {
  /// Requires matching files to have at least one Dart documentation comment.
  HeimdallRule<HeimdallSourceFile> haveDocumentationComment() {
    return satisfy(_fileShouldHaveDocumentationComment());
  }

  /// Requires matching files to have no Dart documentation comments.
  HeimdallRule<HeimdallSourceFile> noHaveDocumentationComment() {
    return satisfy(_fileShouldHaveNoDocumentationComment());
  }
}

HeimdallPredicate<HeimdallSourceFile> _fileHasDocumentationComment() {
  return HeimdallPredicate(
    'have documentation comment',
    (item, _) => _hasDocumentationComment(item),
  );
}

HeimdallPredicate<HeimdallSourceFile> _fileHasNoDocumentationComment() {
  return HeimdallPredicate(
    'not have documentation comment',
    (item, _) => !_hasDocumentationComment(item),
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldHaveDocumentationComment() {
  return HeimdallCondition('have documentation comment', (item, _) {
    final findings = _hasDocumentationComment(item)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              message: 'does not have a documentation comment',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<HeimdallSourceFile> _fileShouldHaveNoDocumentationComment() {
  return HeimdallCondition('not have documentation comment', (item, _) {
    final documentedNodes = _documentationTargets(item).where(_hasComment).toList();
    final findings = documentedNodes.isEmpty
        ? const <HeimdallValidationInfo>[]
        : documentedNodes
              .map(
                (node) => fileNodeFinding(
                  item,
                  node,
                  'has a documentation comment',
                ),
              )
              .toList();
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

bool _hasDocumentationComment(HeimdallSourceFile file) {
  return _documentationTargets(file).any(_hasComment);
}

List<AnnotatedNode> _documentationTargets(HeimdallSourceFile file) {
  return [...file.directives, ...file.declarations];
}

bool _hasComment(AnnotatedNode node) {
  return node.documentationComment != null;
}
