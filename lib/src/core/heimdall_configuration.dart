import 'dart:io';

/// Global Heimdall runtime configuration.
///
/// These settings affect rule execution in the current process. Tests that
/// mutate them should restore previous values to avoid leaking configuration
/// into later tests.
final class HeimdallConfiguration {
  const HeimdallConfiguration._();

  /// When `true`, rules fail if their selector or predicate selects no items.
  ///
  /// Individual rules can still opt out with `allowEmpty()` or
  /// `failOnEmpty(false)`.
  static bool failOnEmptySelection = true;

  /// Regular expressions used to hide known findings from reports.
  static final List<RegExp> ignoredViolationPatterns = [];

  /// Removes all ignored finding patterns.
  static void clearIgnoredViolationPatterns() {
    ignoredViolationPatterns.clear();
  }

  /// Adds a regular expression used to hide matching finding text.
  static void addIgnoredViolationPattern(String pattern) {
    ignoredViolationPatterns.add(RegExp(pattern));
  }

  /// Loads ignored finding patterns from a text file.
  ///
  /// Empty lines and lines starting with `#` are ignored.
  static void loadIgnoredViolationPatterns(String path) {
    final file = File(path);
    if (!file.existsSync()) return;
    for (final line in file.readAsLinesSync()) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      addIgnoredViolationPattern(trimmed);
    }
  }

  /// Returns `true` when [findingText] matches an ignored pattern.
  static bool ignores(String findingText) {
    return ignoredViolationPatterns.any(
      (pattern) => pattern.hasMatch(findingText),
    );
  }
}
