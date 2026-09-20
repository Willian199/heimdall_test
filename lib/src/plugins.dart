import 'package:heimdall_test/src/core.dart';

/// Provides a named group of Heimdall rules.
///
/// Plugins let applications or packages publish reusable architecture checks.
abstract interface class HeimdallRulePlugin {
  /// Human-readable plugin name.
  String get name;

  /// Rules exposed by this plugin.
  Iterable<PluginRule> rules();
}

/// Named executable rule registered by a [HeimdallRulePlugin].
final class PluginRule {
  /// Creates a plugin rule from [name] and a project check callback.
  const PluginRule(this.name, this.check);

  /// Human-readable rule name.
  final String name;

  /// Runs the rule against an imported project.
  final HeimdallReport Function(HeimdallProject project) check;
}

/// Combines several plugins into one plugin surface.
final class CompositeHeimdallPlugin implements HeimdallRulePlugin {
  /// Creates a composite plugin with [name] and child [plugins].
  const CompositeHeimdallPlugin(this.name, this.plugins);

  @override
  final String name;

  /// Plugins whose rules are exposed by this composite.
  final List<HeimdallRulePlugin> plugins;

  @override
  Iterable<PluginRule> rules() => plugins.expand((plugin) => plugin.rules());
}

/// Executes plugin rules against a project.
final class HeimdallRunner {
  /// Creates a runner for [plugins].
  const HeimdallRunner(this.plugins);

  /// Plugins to execute.
  final List<HeimdallRulePlugin> plugins;

  /// Runs all plugin rules and returns their reports in plugin order.
  List<HeimdallReport> run(HeimdallProject project) {
    return [
      for (final plugin in plugins)
        for (final rule in plugin.rules()) rule.check(project),
    ];
  }
}
