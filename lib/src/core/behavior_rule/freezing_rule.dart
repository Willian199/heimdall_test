import 'dart:convert';
import 'dart:io';

import 'package:heimdall_test/heimdall_test.dart';
import 'package:path/path.dart' as p;

/// Rule wrapper that reports only findings not seen in a previous run.
///
/// The current finding set is persisted as JSON at [storePath], allowing legacy
/// violations to stay frozen while new violations fail the build.
final class FreezingHeimdallRule<T> {
  /// Creates a freezing wrapper around [rule].
  const FreezingHeimdallRule(this.rule, {required this.storePath});

  /// Rule whose findings are frozen.
  final HeimdallRule<T> rule;

  /// JSON file used to store known finding text.
  final String storePath;

  /// Runs the wrapped rule and returns only new findings.
  HeimdallReport check(HeimdallProject project) {
    final report = rule.check(project);
    final storeExists = File(storePath).existsSync();
    final known = _readKnownFindings();
    final nextKnown = <String>{};
    final newFindings = <HeimdallValidationInfo>[];
    for (final finding in report.findings) {
      final key = _findingKey(finding, project);
      final isKnown = known.contains(key);
      if (!isKnown) newFindings.add(finding);
      if (!storeExists || isKnown) nextKnown.add(key);
    }

    if (!storeExists || !_setEquals(nextKnown, known)) {
      _writeKnownFindings(nextKnown);
    }

    return HeimdallReport(
      description: '${report.description} (frozen)',
      checkedCount: report.checkedCount,
      findings: newFindings,
      failOnEmptySelection: report.failOnEmptySelection,
    );
  }

  String _findingKey(HeimdallValidationInfo finding, HeimdallProject project) {
    final path = finding.filePath;
    return HeimdallValidationInfo(
      filePath: path == null ? null : p.relative(path, from: project.packageRootPath).replaceAll(r'\', '/'),
      line: finding.line,
      column: finding.column,
      message: finding.message,
    ).toString();
  }

  Set<String> _readKnownFindings() {
    final file = File(storePath);
    if (!file.existsSync()) return {};
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is! List) return {};
    return decoded.whereType<String>().toSet();
  }

  void _writeKnownFindings(Set<String> findings) {
    final file = File(storePath);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(findings.toList()..sort()),
    );
  }

  bool _setEquals(Set<String> left, Set<String> right) {
    return left.length == right.length && left.containsAll(right);
  }
}

/// Adds freezing support to every [HeimdallRule].
extension FreezingHeimdallRuleExtension<T> on HeimdallRule<T> {
  /// Freezes this rule using [storePath] as the violation store.
  FreezingHeimdallRule<T> freeze({required String storePath}) {
    return FreezingHeimdallRule(this, storePath: storePath);
  }
}
