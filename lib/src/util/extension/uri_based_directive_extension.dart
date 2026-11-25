import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_dependency.dart';
import 'package:heimdall_test/src/util/enum/source_uri_kind.dart';
import 'package:heimdall_test/src/util/extension/string_extension.dart';

/// Shared queries for [UriBasedDirective] nodes.
extension UriBasedDirectiveExtension on UriBasedDirective {
  /// Whether at least one branch refers to the Dart SDK.
  bool get hasDartUri => targetUris.any((uri) => uri.uriKind == SourceUriKind.dart);

  /// Whether at least one branch refers to a package library.
  bool get hasPackageUri => targetUris.any((uri) => uri.uriKind == SourceUriKind.package);

  /// Whether at least one branch uses a relative URI.
  bool get hasRelativeUri => targetUris.any((uri) => uri.uriKind == SourceUriKind.relative);

  /// Whether at least one URI contains an upward path segment.
  bool get hasUpwardRelativeUri => targetUris.any((uri) => uri.hasUpwardPathSegments);

  /// Whether at least one branch names a file in its own directory.
  bool get hasSameDirectoryRelativeUri => targetUris.any((uri) => uri.isSameDirectoryRelativeUri);

  /// Whether a local dependency branch lacks a resolved target.
  bool get isUnresolvedLocalDirective => targetUris.any(
    (uri) => (uri.uriKind == SourceUriKind.relative || uri.uriKind == SourceUriKind.package) && !resolvedTargets.any((target) => target.uri == uri),
  );

  /// URI literals matching a rule, including every conditional branch.
  Iterable<StringLiteral> matchingUris(bool Function(String) matches) sync* {
    final configurations = switch (this) {
      ImportDirective(:final configurations) || ExportDirective(:final configurations) => configurations,
      _ => <Configuration>[],
    };
    for (final literal in [uri, ...configurations.map((configuration) => configuration.uri)]) {
      if (literal.stringValue case final value? when matches(value)) {
        yield literal;
      }
    }
  }
}
