import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/file_features/helpers/public_class_name_mismatch.dart';

/// Fluent predicate builder for source-file rules.
///
/// Each predicate narrows the files that the later condition chain will
/// validate. The default selection is every imported file.
final class FilePredicateBuilder implements HeimdallPredicateBuilder<HeimdallSourceFile, FilePredicateBuilder, FileShouldBuilder> {
  /// Creates a file predicate builder.
  FilePredicateBuilder({required this.inverted});

  /// Whether generated rules should invert their final condition.
  final bool inverted;
  HeimdallPredicate<HeimdallSourceFile> _predicate = alwaysFile;
  bool _useOr = false;
  bool _negateNext = false;

  @override
  FilePredicateBuilder and() {
    _useOr = false;
    return this;
  }

  @override
  FilePredicateBuilder or() {
    _useOr = true;
    return this;
  }

  @override
  FilePredicateBuilder not() {
    assert(!_negateNext, 'not() called twice in sequence');
    _negateNext = true;
    return this;
  }

  @override
  FilePredicateBuilder satisfy(
    HeimdallPredicate<HeimdallSourceFile> predicate,
  ) {
    final nextPredicate = _negateNext ? predicate.not() : predicate;
    _predicate = _predicate == alwaysFile && !_useOr ? nextPredicate : (_useOr ? _predicate.or(nextPredicate) : _predicate.and(nextPredicate));
    _useOr = false;
    _negateNext = false;
    return this;
  }

  @override
  FileShouldBuilder should() {
    return FileShouldBuilder(predicate: _predicate, inverted: inverted);
  }

  /// Selects files that declare at most one public class.
  FilePredicateBuilder haveAtMostOnePublicClass() {
    return satisfy(fileHasAtMostOnePublicClass());
  }

  /// Builds a file-level rule that reports every matching file.
  ///
  /// This is useful for policies such as "legacy path must not contain files".
  /// Call `.allowEmpty()` on the returned rule when absence is expected.
  HeimdallRule<HeimdallSourceFile> shouldNotExist() {
    final filePredicate = _predicate;
    return HeimdallRule(
      descriptionPrefix: _fileRulePrefix(
        inverted: inverted,
        predicateDescription: filePredicate.description,
      ),
      selector: (project) => project.files,
      predicate: filePredicate,
      condition: HeimdallCondition('not exist', (item, _) {
        final findings = <HeimdallValidationInfo>[
          HeimdallValidationInfo(
            filePath: item.absolutePath,
            line: 1,
            column: 1,
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

  /// Selects files that contain only whitespace.
  FilePredicateBuilder beEmpty() {
    return satisfy(
      HeimdallPredicate(
        'be empty',
        (item, _) => item.content.trim().isEmpty,
      ),
    );
  }

  /// Selects files that are not empty.
  FilePredicateBuilder notBeEmpty() {
    return satisfy(
      HeimdallPredicate(
        'not be empty',
        (item, _) => item.content.trim().isNotEmpty,
      ),
    );
  }

  /// Predicate that accepts every imported file.
  static const alwaysFile = HeimdallPredicate<HeimdallSourceFile>(
    'all files',
    _alwaysFilePredicate,
  );

  static bool _alwaysFilePredicate(
    HeimdallSourceFile _,
    HeimdallProject project,
  ) => true;
}

String _fileRulePrefix({
  required bool inverted,
  required String predicateDescription,
}) {
  final subject = inverted ? 'no files' : 'files';
  if (predicateDescription == FilePredicateBuilder.alwaysFile.description) {
    return subject;
  }
  return '$subject that $predicateDescription';
}
