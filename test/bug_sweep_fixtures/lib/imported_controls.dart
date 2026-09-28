import 'dynamic_source.dart' as source;
import 'dynamic_source.dart' hide importedValue, importedFunction;
import 'dynamic_barrel.dart' as filtered show importedFunction;

final safeShadowedPrefix = () {
  const source = (importedValue: 1);
  return source.importedValue;
};
final safeShadowedLocal = () {
  const importedValue = 1;
  return importedValue;
};
// Unresolved/hidden references must stay unknown in syntax-only analysis.
final safeHiddenValue = () => importedValue;
final safeHiddenFunction = () => importedFunction();
final safeHiddenBarrelValue = () => filtered.importedValue;
final safePrivateValue = () => source._privateValue;
