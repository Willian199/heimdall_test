export 'model/heimdall_declaration.dart';
export 'model/heimdall_dependency.dart';
export 'model/heimdall_member.dart';
export 'model/heimdall_project.dart';
export 'model/heimdall_source_file.dart';

/// Simple predicate for Dart elements.
///
/// Kept as a convenience for APIs that accept filter functions without
/// depending on the complete Heimdall DSL.
///
/// Example:
/// ```dart
/// HeimdallElementPredicate<CompilationUnitMember> publicOnly =
///     (element) => element.name.startsWith('_') == false;
/// ```
typedef HeimdallElementPredicate<T> = bool Function(T element);
