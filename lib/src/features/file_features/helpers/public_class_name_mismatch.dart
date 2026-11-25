import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/util/extension/string_extension.dart';
import 'package:path/path.dart' as p;

/// Creates a predicate that accepts files with zero or one public class.
HeimdallPredicate<HeimdallSourceFile> fileHasAtMostOnePublicClass() {
  return HeimdallPredicate(
    'have at most one public class',
    (item, _) => item.publicClassDeclarations.length <= 1,
  );
}

/// Creates a condition requiring files to declare at most one public class.
HeimdallCondition<HeimdallSourceFile> fileShouldHaveAtMostOnePublicClass() {
  const description = 'have at most one public class';
  return HeimdallCondition(description, (item, _) {
    final classes = item.publicClassDeclarations;
    final findings = classes.length <= 1
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              line: classes[1].line,
              message: 'declares more than one public class',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

/// Returns the public-class file-name mismatch for [item], if one exists.
///
/// When [className] is provided, only that public class name is considered.
/// Files with zero or multiple matching public classes do not produce a
/// mismatch because the file-name convention is only meaningful for one class.
PublicClassNameMismatch? publicClassNameMismatch(
  HeimdallSourceFile item, {
  String? className,
}) {
  final classes = item.publicClassDeclarations
      .where(
        (declaration) => className == null || declaration.name == className,
      )
      .toList();
  if (classes.length != 1) {
    return null;
  }

  final declaration = classes.single;
  final expected = declaration.name.toSnakeCase();
  final actual = p.basenameWithoutExtension(item.relativePath);
  if (actual == expected) {
    return null;
  }
  return PublicClassNameMismatch(declaration, expected);
}

/// Describes a public class whose expected file name differs from its file.
final class PublicClassNameMismatch {
  /// Creates a public-class file-name mismatch descriptor.
  const PublicClassNameMismatch(this.declaration, this.expectedFileName);

  /// Public class declaration whose name defines the expected file name.
  final CompilationUnitMember declaration;

  /// Expected snake_case file name without the `.dart` extension.
  final String expectedFileName;
}
