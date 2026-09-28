import 'package:heimdall_test/src/core.dart';
import 'package:heimdall_test/src/features/queries/declaration_dependency_queries.dart';
import 'package:heimdall_test/src/features/queries/declaration_lookup_queries.dart';

/// Identifies supported SDK types without mistaking a local type for an SDK type.
String? sdkTypeName(CompilationUnitMember source, String reference, HeimdallProject project) {
  final pieces = reference.split('.');
  final name = pieces.last;
  final prefix = pieces.length == 2 ? pieces.first : null;
  if (visibleTypeReferenceDeclarationsFrom(source, project, importPrefix: prefix).any((item) => item.name == name)) {
    return null;
  }
  final library = switch (name) {
    'Future' || 'FutureOr' || 'Stream' || 'Completer' || 'StreamController' || 'StreamSubscription' => 'dart:async',
    'Queue' ||
    'ListQueue' ||
    'DoubleLinkedQueue' ||
    'HashSet' ||
    'LinkedHashSet' ||
    'SplayTreeSet' ||
    'HashMap' ||
    'LinkedHashMap' ||
    'SplayTreeMap' => 'dart:collection',
    'Uint8List' ||
    'Int8List' ||
    'Uint16List' ||
    'Int16List' ||
    'Uint32List' ||
    'Int32List' ||
    'Uint64List' ||
    'Int64List' ||
    'Uint8ClampedList' ||
    'Float32List' ||
    'Float64List' => 'dart:typed_data',
    'Object' ||
    'Never' ||
    'Null' ||
    'num' ||
    'int' ||
    'double' ||
    'bool' ||
    'String' ||
    'Pattern' ||
    'Comparable' ||
    'List' ||
    'Set' ||
    'Map' ||
    'Iterable' ||
    'Iterator' ||
    'Function' ||
    'Record' ||
    'Enum' => 'dart:core',
    _ => null,
  };
  if (library == null) {
    return null;
  }
  final imports = dependenciesFrom(source, project).whereType<ImportDirective>();
  if (prefix == null && library == 'dart:core' && !imports.any((item) => item.uri.stringValue == library)) {
    return name;
  }
  return imports.any(
        (item) =>
            item.uri.stringValue == library &&
            item.prefix?.name == prefix &&
            item.combinators.every(
              (combinator) => switch (combinator) {
                ShowCombinator() => combinator.shownNames.any((item) => item.name == name),
                HideCombinator() => !combinator.hiddenNames.any((item) => item.name == name),
              },
            ),
      )
      ? name
      : null;
}
