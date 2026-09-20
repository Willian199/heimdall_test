import 'package:heimdall_test/heimdall_test.dart';

/// DSL entry point for source-file rules.
///
/// This rule family evaluates the files imported into [HeimdallProject.files].
final class FileRules implements HeimdallRules<FilePredicateBuilder, FileShouldBuilder> {
  /// Creates a file rule entry point.
  const FileRules({required this.inverted});

  /// Whether generated rules should invert their final condition.
  final bool inverted;

  /// Starts selecting files with predicates.
  @override
  FilePredicateBuilder that() => FilePredicateBuilder(inverted: inverted);

  /// Starts asserting conditions over all imported files.
  @override
  FileShouldBuilder should() => FilePredicateBuilder(inverted: inverted).should();
}
