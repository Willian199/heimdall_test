import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/file_features/helpers/source_file_location.dart';

/// Predicate-side DSL for extension declaration rules.
extension FileDeclareExtensionOnPredicateRules on FilePredicateBuilder {
  /// Selects files that declare an extension on [extendedType].
  FilePredicateBuilder declareExtensionOn(String extendedType) {
    return satisfy(_fileDeclaresExtensionOn(extendedType));
  }

  /// Selects files that do not declare an extension on [extendedType].
  FilePredicateBuilder noDeclareExtensionOn(String extendedType) {
    return satisfy(_fileDoesNotDeclareExtensionOn(extendedType));
  }

  /// Selects files that declare extensions on every type in [extendedTypes].
  FilePredicateBuilder declareAllExtensionsOn(Iterable<String> extendedTypes) {
    final typeList = extendedTypes.toNonEmptyList('extendedTypes');
    return satisfy(
      HeimdallPredicate.allOf(
        typeList.map(_fileDeclaresExtensionOn),
        description: 'declare extensions on all of ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects files that declare an extension on at least one type in [extendedTypes].
  FilePredicateBuilder declareAnyExtensionOn(Iterable<String> extendedTypes) {
    final typeList = extendedTypes.toNonEmptyList('extendedTypes');
    return satisfy(
      HeimdallPredicate.anyOf(
        typeList.map(_fileDeclaresExtensionOn),
        description: 'declare extension on any of ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects files that declare no extensions on [extendedTypes].
  FilePredicateBuilder declareNoExtensionsOn(Iterable<String> extendedTypes) {
    final typeList = extendedTypes.toNonEmptyList('extendedTypes');
    return satisfy(
      HeimdallPredicate.noneOf(
        typeList.map(_fileDeclaresExtensionOn),
        description: 'declare extension on none of ${typeList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for extension declaration rules.
extension FileDeclareExtensionOnShouldRules on FileShouldBuilder {
  /// Requires matching files to declare an extension on [extendedType].
  HeimdallRule<HeimdallSourceFile> declareExtensionOn(String extendedType) {
    return satisfy(_fileShouldDeclareExtensionOn(extendedType));
  }

  /// Requires matching files to not declare an extension on [extendedType].
  HeimdallRule<HeimdallSourceFile> noDeclareExtensionOn(String extendedType) {
    return satisfy(_fileShouldNotDeclareExtensionOn(extendedType));
  }

  /// Requires matching files to declare extensions on every type in [extendedTypes].
  HeimdallRule<HeimdallSourceFile> declareAllExtensionsOn(
    Iterable<String> extendedTypes,
  ) {
    final typeList = extendedTypes.toNonEmptyList('extendedTypes');
    return satisfy(
      HeimdallCondition.allOf(
        typeList.map(_fileShouldDeclareExtensionOn),
        description: 'declare extensions on all of ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to declare an extension on at least one type in [extendedTypes].
  HeimdallRule<HeimdallSourceFile> declareAnyExtensionOn(
    Iterable<String> extendedTypes,
  ) {
    final typeList = extendedTypes.toNonEmptyList('extendedTypes');
    return satisfy(
      HeimdallCondition.anyOf(
        typeList.map(_fileShouldDeclareExtensionOn),
        description: 'declare extension on any of ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to declare no extensions on [extendedTypes].
  HeimdallRule<HeimdallSourceFile> declareNoExtensionsOn(
    Iterable<String> extendedTypes,
  ) {
    final typeList = extendedTypes.toNonEmptyList('extendedTypes');
    return satisfy(
      HeimdallCondition.noneOf(
        typeList.map(_fileShouldDeclareExtensionOn),
        description: 'declare extension on none of ${typeList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<HeimdallSourceFile> _fileShouldDeclareExtensionOn(
  String extendedType,
) {
  return HeimdallCondition('declare extension on $extendedType', (item, _) {
    final findings = _declaresExtensionOn(item, extendedType)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              message: 'does not declare extension on $extendedType',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallPredicate<HeimdallSourceFile> _fileDeclaresExtensionOn(
  String extendedType,
) {
  return HeimdallPredicate(
    'declare extension on $extendedType',
    (item, _) => _declaresExtensionOn(item, extendedType),
  );
}

bool _declaresExtensionOn(HeimdallSourceFile item, String extendedType) {
  return item.extensionDeclarations.any(
    (declaration) => _extensionOnType(declaration) == extendedType,
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldNotDeclareExtensionOn(
  String extendedType,
) {
  return HeimdallCondition('not declare extension on $extendedType', (item, _) {
    final findings = item.extensionDeclarations
        .where((declaration) => _extensionOnType(declaration) == extendedType)
        .map(
          (declaration) => fileNodeFinding(
            item,
            declaration,
            'declares forbidden extension on $extendedType',
            offset: declaration.onClause?.extendedType.offset,
          ),
        )
        .toList();
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallPredicate<HeimdallSourceFile> _fileDoesNotDeclareExtensionOn(
  String extendedType,
) {
  return HeimdallPredicate(
    'not declare extension on $extendedType',
    (item, _) => !item.extensionDeclarations.any(
      (declaration) => _extensionOnType(declaration) == extendedType,
    ),
  );
}

String? _extensionOnType(ExtensionDeclaration declaration) {
  return declaration.onClause?.extendedType.toSource();
}
