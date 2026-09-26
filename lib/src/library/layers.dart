import 'package:heimdall_test/src/core.dart';
import 'package:heimdall_test/src/features/queries/declaration_dependency_queries.dart';

/// Creates a layer architecture builder.
HeimdallLayers heimdallLayers() => HeimdallLayers();

/// Builder for layer-based architecture rules.
///
/// Define layers by path patterns, add access constraints, and call [asRule] to
/// produce an executable Heimdall rule.
final class HeimdallLayers {
  final Map<String, List<String>> _layers = {};
  final List<_LayerConstraint> _constraints = [];
  bool _onlyDependenciesInLayers = false;

  /// Starts defining a layer named [name].
  HeimdallLayerDefinition layer(String name) => HeimdallLayerDefinition._(this, name);

  /// Ignores dependencies whose target is not assigned to any declared layer.
  HeimdallLayers consideringOnlyDependenciesInLayers() {
    _onlyDependenciesInLayers = true;
    return this;
  }

  /// Reports dependencies whose target is outside all declared layers.
  HeimdallLayers consideringAllDependencies() {
    _onlyDependenciesInLayers = false;
    return this;
  }

  /// Starts defining access rules for layer [name].
  HeimdallLayerGate whereLayer(String name) => HeimdallLayerGate._(this, name);

  /// Builds the layer architecture rule.
  HeimdallRule<CompilationUnitMember> asRule() {
    return HeimdallRule(
      descriptionPrefix: 'Heimdall layer sight',
      selector: (project) => project.typeDeclarations.where(
        (declaration) => _layerOf(declaration) != null,
      ),
      predicate: const HeimdallPredicate(
        'classes in declared layers',
        _alwaysLayerCandidate,
      ),
      condition: HeimdallCondition('satisfy layer constraints', _checkDeclaration),
    );
  }

  HeimdallFindings<CompilationUnitMember> _checkDeclaration(
    CompilationUnitMember item,
    HeimdallProject project,
  ) {
    final findings = <HeimdallValidationInfo>[];
    final ownLayer = _layerOf(item);
    if (ownLayer != null) {
      for (final dependency in declarationDependenciesFrom(item, project)) {
        final targetLayer = _layerOf(dependency.target);
        if (targetLayer == null) {
          if (!_onlyDependenciesInLayers) {
            findings.add(
              HeimdallValidationInfo(
                filePath: item.sourcePath,
                line: dependency.directive.line,
                message: '${item.name} in layer $ownLayer accesses undeclared layer via ${dependency.targetUri}',
              ),
            );
          }
          continue;
        }
        findings.addAll(
          _accessfindings(
            item,
            dependency.directive,
            dependency.targetUri,
            ownLayer,
            targetLayer,
          ),
        );
      }
    }
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  }

  List<HeimdallValidationInfo> _accessfindings(
    CompilationUnitMember item,
    Directive dependency,
    String dependencyUri,
    String ownLayer,
    String targetLayer,
  ) {
    final findings = <HeimdallValidationInfo>[];
    for (final constraint in _constraints.where(
      (rule) => rule.layer == ownLayer,
    )) {
      if (!constraint.allowsAccessTo(targetLayer)) {
        findings.add(
          HeimdallValidationInfo(
            filePath: item.sourcePath,
            line: dependency.line,
            message: '${item.name} in layer $ownLayer may not access $targetLayer via $dependencyUri',
          ),
        );
      }
    }
    for (final constraint in _constraints.where(
      (rule) => rule.layer == targetLayer,
    )) {
      if (!constraint.allowsAccessFrom(ownLayer)) {
        findings.add(
          HeimdallValidationInfo(
            filePath: item.sourcePath,
            line: dependency.line,
            message: '${item.name} in layer $ownLayer may not access $targetLayer via $dependencyUri',
          ),
        );
      }
    }
    return findings;
  }

  String? _layerOf(CompilationUnitMember declaration) {
    for (final entry in _layers.entries) {
      if (entry.value.any(
        (pattern) => pathMatches(declaration.relativePath, pattern),
      )) {
        return entry.key;
      }
    }
    return null;
  }
}

/// Fluent step used to assign path patterns to a layer.
final class HeimdallLayerDefinition {
  HeimdallLayerDefinition._(this._layers, this._name);

  final HeimdallLayers _layers;
  final String _name;

  /// Defines the layer by source path patterns.
  HeimdallLayers definedBy(List<String> pathPatterns) {
    _layers._layers[_name] = pathPatterns;
    return _layers;
  }
}

/// Fluent step used to declare layer access constraints.
final class HeimdallLayerGate {
  HeimdallLayerGate._(this._layers, this._name);

  final HeimdallLayers _layers;
  final String _name;

  /// Allows this layer to access only [layerNames].
  HeimdallLayers mayOnlyAccessLayers(List<String> layerNames) {
    _layers._constraints.add(_LayerConstraint.onlyAccess(_name, layerNames));
    return _layers;
  }

  /// Prevents this layer from accessing any other declared layer.
  HeimdallLayers mayNotAccessAnyLayer() {
    _layers._constraints.add(_LayerConstraint.onlyAccess(_name, const []));
    return _layers;
  }

  /// Allows this layer to be accessed only by [layerNames].
  HeimdallLayers mayOnlyBeAccessedByLayers(List<String> layerNames) {
    _layers._constraints.add(
      _LayerConstraint.onlyBeAccessedBy(_name, layerNames),
    );
    return _layers;
  }

  /// Prevents any declared layer from accessing this layer.
  HeimdallLayers mayNotBeAccessedByAnyLayer() {
    _layers._constraints.add(
      _LayerConstraint.onlyBeAccessedBy(_name, const []),
    );
    return _layers;
  }
}

final class _LayerConstraint {
  const _LayerConstraint.onlyAccess(this.layer, this.layers) : direction = _LayerConstraintDirection.access;

  const _LayerConstraint.onlyBeAccessedBy(this.layer, this.layers) : direction = _LayerConstraintDirection.beAccessedBy;

  final String layer;
  final List<String> layers;
  final _LayerConstraintDirection direction;

  bool allowsAccessTo(String targetLayer) {
    if (direction != _LayerConstraintDirection.access) {
      return true;
    }
    return layers.contains(targetLayer);
  }

  bool allowsAccessFrom(String sourceLayer) {
    if (direction != _LayerConstraintDirection.beAccessedBy) {
      return true;
    }
    return layers.contains(sourceLayer);
  }
}

enum _LayerConstraintDirection { access, beAccessedBy }

bool _alwaysLayerCandidate(CompilationUnitMember item, HeimdallProject _) => true;
