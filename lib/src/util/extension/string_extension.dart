import 'package:heimdall_test/src/util/enum/source_uri_kind.dart';

abstract final class _RegexPatterns {
  static final camelCaseBoundary = RegExp('([a-z0-9])([A-Z])');
  static final acronymBoundary = RegExp('([A-Z]+)([A-Z][a-z])');
}

/// Shared queries for [String] nodes.
extension StringExtension on String {
  /// Converts camelCase and PascalCase names to snake_case, retaining acronyms.
  String toSnakeCase() => replaceAllMapped(
    _RegexPatterns.camelCaseBoundary,
    (match) => '${match.group(1)}_${match.group(2)}',
  ).replaceAllMapped(_RegexPatterns.acronymBoundary, (match) => '${match.group(1)}_${match.group(2)}').toLowerCase();

  /// The kind of dependency represented by this URI.
  SourceUriKind get uriKind {
    if (startsWith('dart:')) {
      return SourceUriKind.dart;
    }
    if (startsWith('package:')) {
      return SourceUriKind.package;
    }
    return Uri.tryParse(this)?.hasScheme == false ? SourceUriKind.relative : SourceUriKind.other;
  }

  /// Whether the URI text contains an upward path segment.
  bool get hasUpwardPathSegments => this == '..' || startsWith('../') || contains('/../');

  /// Whether this relative URI names a file in the current directory.
  bool get isSameDirectoryRelativeUri {
    if (Uri.tryParse(this)?.hasScheme != false || hasUpwardPathSegments) {
      return false;
    }
    return !contains('/') || startsWith('./') && !substring(2).contains('/');
  }
}
