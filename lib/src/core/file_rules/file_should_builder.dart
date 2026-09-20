import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/file_features/helpers/public_class_name_mismatch.dart';

/// Fluent condition builder for source-file rules.
///
/// Conditions are evaluated for each file selected by the file rule scope and
/// predicate chain.
final class FileShouldBuilder implements HeimdallShouldBuilder<HeimdallSourceFile, FileShouldBuilder> {
  /// Creates a file condition builder.
  FileShouldBuilder({required this.predicate, required this.inverted}) : _descriptionPrefix = null, _selector = null, _failOnEmptySelection = true;

  /// Creates a file condition builder that continues an existing [rule].
  FileShouldBuilder.fromRule(
    HeimdallRule<HeimdallSourceFile> rule, {
    required bool useOr,
  }) : predicate = rule.predicate,
       inverted = rule.inverted,
       _condition = rule.condition,
       _useOr = useOr,
       _descriptionPrefix = rule.descriptionPrefix ?? rule.description,
       _selector = rule.selector,
       _failOnEmptySelection = rule.failOnEmptySelection;

  /// Predicate that selects checked files.
  final HeimdallPredicate<HeimdallSourceFile> predicate;

  /// Whether generated rules should invert their final condition.
  final bool inverted;
  HeimdallCondition<HeimdallSourceFile>? _condition;
  bool _useOr = false;
  bool _negateNext = false;
  final String? _descriptionPrefix;
  final Selector<HeimdallSourceFile>? _selector;
  bool _failOnEmptySelection;

  @override
  FileShouldBuilder andShould() {
    _useOr = false;
    return this;
  }

  @override
  FileShouldBuilder orShould() {
    _useOr = true;
    return this;
  }

  @override
  FileShouldBuilder not() {
    assert(!_negateNext, 'not() called twice in sequence');
    _negateNext = true;
    return this;
  }

  /// Allows the generated rule to select no files.
  FileShouldBuilder allowEmpty() => failOnEmpty(false);

  /// Configures whether the generated rule should fail on an empty selection.
  FileShouldBuilder failOnEmpty(bool value) {
    _failOnEmptySelection = value;
    return this;
  }

  @override
  HeimdallRule<HeimdallSourceFile> satisfy(
    HeimdallCondition<HeimdallSourceFile> condition,
  ) {
    final nextCondition = _negateNext ? condition.not() : condition;
    _condition = _condition == null
        ? nextCondition
        : _useOr
        ? _condition!.or(nextCondition)
        : _condition!.and(nextCondition);
    _useOr = false;
    _negateNext = false;
    return _build();
  }

  /// Requires matching files to declare at most one public class.
  HeimdallRule<HeimdallSourceFile> haveAtMostOnePublicClass() {
    return satisfy(fileShouldHaveAtMostOnePublicClass());
  }

  HeimdallRule<HeimdallSourceFile> _build() {
    final condition = _condition;
    if (condition == null) {
      throw StateError('A rule needs at least one condition.');
    }
    final prefix = _descriptionPrefix ?? _fileRulePrefix(inverted: inverted, predicateDescription: predicate.description);

    return HeimdallRule(
      descriptionPrefix: prefix,
      selector: _selector ?? (project) => project.files,
      predicate: predicate,
      condition: condition,
      inverted: inverted,
      failOnEmptySelection: _failOnEmptySelection,
    );
  }

  /// Requires matching files to contain only whitespace.
  HeimdallRule<HeimdallSourceFile> beEmpty() {
    return satisfy(
      HeimdallCondition('be empty', (item, _) {
        final List<HeimdallValidationInfo> findings;

        if (item.content.trim().isEmpty) {
          findings = const <HeimdallValidationInfo>[];
        } else {
          findings = [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              line: 1,
              column: 1,
              message: 'is not empty',
            ),
          ];
        }

        return HeimdallFindings(
          subject: item,
          passed: findings.isEmpty,
          findings: findings,
        );
      }),
    );
  }

  /// Requires matching files to not contain only whitespace.
  HeimdallRule<HeimdallSourceFile> noBeEmpty() {
    return satisfy(
      HeimdallCondition('not be empty', (item, _) {
        final List<HeimdallValidationInfo> findings;

        if (item.content.trim().isNotEmpty) {
          findings = const <HeimdallValidationInfo>[];
        } else {
          findings = [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              line: 1,
              column: 1,
              message: 'is empty',
            ),
          ];
        }

        return HeimdallFindings(
          subject: item,
          passed: findings.isEmpty,
          findings: findings,
        );
      }),
    );
  }

  /// Requires at least one matching file to exist.
  HeimdallRule<HeimdallSourceFile> exist() {
    return satisfy(
      HeimdallCondition('exist', (item, _) {
        return HeimdallFindings(
          subject: item,
          passed: true,
        );
      }),
    );
  }
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
