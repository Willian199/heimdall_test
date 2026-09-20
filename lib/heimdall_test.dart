/// Architecture testing DSL for Dart source trees.
///
/// Import source with `HeimdallFileImporter`, build rules through `Heimdall`,
/// and assert the returned `HeimdallReport` in tests.
library;

export 'src/core.dart';
export 'src/features/class_features/export.dart';
export 'src/features/file_features/export.dart';
export 'src/features/member_features/export.dart';
export 'src/heimdall.dart';
export 'src/library_rules.dart';
export 'src/plugins.dart';
