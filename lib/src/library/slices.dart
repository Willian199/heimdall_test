import 'dart:collection';

import 'package:heimdall_test/src/core.dart';

/// Builder for slice-based dependency rules.
///
/// Slices are inferred from a path pattern containing `(*)`, such as
/// `lib/src/features/(*)`.
final class HeimdallSlices {
  /// Creates a slice builder using [pattern].
  const HeimdallSlices.matching(String pattern) : _pattern = pattern;

  final String _pattern;

  /// Builds a rule that reports dependency cycles between slices.
  HeimdallRule<HeimdallProject> shouldBeFreeOfCycles() {
    return HeimdallRule(
      descriptionPrefix: 'Heimdall slices matching $_pattern',
      selector: (project) => [project],
      predicate: const HeimdallPredicate('imported project', _allProjects),
      condition: HeimdallCondition('be free of cycles', (item, project) {
        final cycles = _findCycles(_buildGraph(project));
        final findings = cycles
            .map(
              (cycle) => HeimdallValidationInfo(
                message: 'Cycle detected: ${cycle.join(' -> ')}',
              ),
            )
            .toList();
        return HeimdallFindings(
          subject: item,
          passed: findings.isEmpty,
          findings: findings,
        );
      }),
    );
  }

  /// Builds a rule that reports any dependency from one slice to another.
  HeimdallRule<HeimdallProject> shouldNotDependOnEachOther({
    Iterable<String> sharedSlices = const [],
  }) {
    final sharedSliceSet = sharedSlices.map(normalizePath).toSet();
    return HeimdallRule(
      descriptionPrefix: 'Heimdall slices matching $_pattern',
      selector: (project) => [project],
      predicate: const HeimdallPredicate('imported project', _allProjects),
      condition: HeimdallCondition('not depend on each other', (item, project) {
        final graph = _buildGraph(project, sharedSliceSet: sharedSliceSet);
        final findings = [
          for (final entry in graph.entries)
            for (final target in entry.value) HeimdallValidationInfo(message: 'Slice ${entry.key} depends on $target'),
        ];
        return HeimdallFindings(
          subject: item,
          passed: findings.isEmpty,
          findings: findings,
        );
      }),
    );
  }

  Map<String, Set<String>> _buildGraph(
    HeimdallProject project, {
    Set<String> sharedSliceSet = const {},
  }) {
    final graph = <String, Set<String>>{};
    for (final file in project.files) {
      final sourceSlice = _sliceId(file.relativePath);
      if (sourceSlice == null) continue;
      graph.putIfAbsent(sourceSlice, LinkedHashSet.new);
      for (final dependency in file.resolvedDependencies) {
        for (final targetFile in dependency.targetFiles) {
          final targetPaths = {
            targetFile.relativePath,
            for (final target in project.exportedTypeDeclarationsOf(targetFile)) target.relativePath,
          };
          for (final targetPath in targetPaths) {
            final targetSlice = _sliceId(targetPath);
            if (targetSlice != null && targetSlice != sourceSlice && !sharedSliceSet.contains(normalizePath(targetSlice))) {
              graph[sourceSlice]!.add(targetSlice);
            }
          }
        }
      }
    }
    return graph;
  }

  String? _sliceId(String relativePath) {
    final normalizedPattern = normalizePath(_pattern);
    final normalizedPath = normalizePath(relativePath);
    if (!normalizedPattern.contains('(*)')) {
      return pathMatches(normalizedPath, normalizedPattern) ? normalizedPath : null;
    }
    return captureSlicePathSegment(normalizedPath, normalizedPattern);
  }
}

bool _allProjects(HeimdallProject _, HeimdallProject project) => true;

List<List<String>> _findCycles(Map<String, Set<String>> graph) {
  final cycles = <List<String>>[];
  final stack = <String>[];
  final visited = <String>{};

  void visit(String node) {
    if (stack.contains(node)) {
      cycles.add(stack.skip(stack.indexOf(node)).toList()..add(node));
      return;
    }
    if (!visited.add(node)) return;
    stack.add(node);
    for (final next in graph[node] ?? const <String>{}) {
      visit(next);
      if (cycles.length >= 100) return;
    }
    stack.removeLast();
  }

  graph.keys.forEach(visit);
  return cycles;
}
