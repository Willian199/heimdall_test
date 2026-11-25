import 'package:heimdall_test/src/core.dart';
import 'package:heimdall_test/src/features/queries/declaration_dependency_queries.dart';
import 'package:heimdall_test/src/util/enum/layer_constraint_direction.dart';

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
      selector: (project) => project.declarations.where(
        (declaration) => _layerOf(declaration) != null,
      ),
      predicate: const HeimdallPredicate(
        'declarations in declared layers',
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
    final seen = <(Directive, String, String?)>{};
    final ownLayer = _layerOf(item);
    if (ownLayer != null) {
      for (final dependency in allDeclarationDependenciesFrom(item, project)) {
        final targetLayer = _layerOf(dependency.target);
        if (!seen.add((dependency.directive, dependency.targetUri, targetLayer))) {
          continue;
        }
        if (targetLayer == null) {
          if (_onlyDependenciesInLayers) {
            continue;
          }
        } else if (!_constraints.any((rule) => rule.forbidsAccess(ownLayer, targetLayer))) {
          continue;
        }
        final access = targetLayer == null ? 'accesses undeclared layer' : 'may not access $targetLayer';
        findings.add(
          HeimdallValidationInfo(
            filePath: dependency.directive.originPath,
            line: dependency.directive.line,
            message: '${item.name} in layer $ownLayer $access via ${dependency.targetUri}',
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
  const _LayerConstraint.onlyAccess(this.layer, this.layers) : direction = LayerConstraintDirection.access;

  const _LayerConstraint.onlyBeAccessedBy(this.layer, this.layers) : direction = LayerConstraintDirection.beAccessedBy;

  final String layer;
  final List<String> layers;
  final LayerConstraintDirection direction;

  bool forbidsAccess(String sourceLayer, String targetLayer) => switch (direction) {
    LayerConstraintDirection.access => layer == sourceLayer && !layers.contains(targetLayer),
    LayerConstraintDirection.beAccessedBy => layer == targetLayer && !layers.contains(sourceLayer),
  };
}

bool _alwaysLayerCandidate(CompilationUnitMember item, HeimdallProject _) => true;
