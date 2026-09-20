# Plugins and runner

- `rules`
- `run`

`HeimdallRulePlugin.rules()` returns reusable `PluginRule` entries. `HeimdallRunner.run(project)` evaluates the registered plugins and returns reports. Call `assertNoFindings()` on each report to fail a test when a plugin rule reports violations.
