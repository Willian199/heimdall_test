import 'dynamic_source.dart' show importedValue, importedFunction, ImportedContainer;
import 'dynamic_source.dart' as source;
import 'dynamic_barrel.dart' as barrel;
import 'dynamic_source.dart' as sourceAgain;

final importedShownValue = () => importedValue;

final importedShownCall = () => importedFunction();

final importedPrefixedValue = () => source.importedValue;

final importedPrefixedCall = () => source.importedFunction();

final importedBarrelValue = () => barrel.importedValue;

final importedBarrelCall = () => barrel.importedFunction();

final importedInstanceGetter = () => ImportedContainer().value;

final importedInstanceMethod = () => ImportedContainer().fetch();

final importedPrefixedInstanceGetter = () => sourceAgain.ImportedContainer().value;

final importedPrefixedInstanceMethod = () => sourceAgain.ImportedContainer().fetch();

final importedShownLocalValue = () {
  final local = importedValue;
  return local;
};

final importedShownConditionalValue = () {
  if (true) return importedValue;
  return null;
};

final importedShownListValue = () => [importedValue];

final importedShownRecordValue = () => (value: importedValue);

final importedPrefixedLocalValue = () {
  final local = source.importedValue;
  return local;
};

final importedPrefixedConditionalValue = () {
  if (true) return source.importedValue;
  return null;
};

final importedPrefixedListValue = () => [source.importedValue];

final importedPrefixedRecordValue = () => (value: source.importedValue);

final importedBarrelLocalValue = () {
  final local = barrel.importedValue;
  return local;
};

final importedBarrelConditionalValue = () {
  if (true) return barrel.importedValue;
  return null;
};

final importedBarrelListValue = () => [barrel.importedValue];

final importedBarrelRecordValue = () => (value: barrel.importedValue);

final importedShownMapValue = () => {'key': importedValue};

final importedShownIndexValue = () => {'key': importedValue}['key'];

final importedShownCoalesceValue = () => importedValue ?? null;

final importedShownCompareValue = () => importedValue == null;

final importedPrefixedMapValue = () => {'key': source.importedValue};

final importedPrefixedIndexValue = () => {'key': source.importedValue}['key'];

final importedPrefixedCoalesceValue = () => source.importedValue ?? null;

final importedPrefixedCompareValue = () => source.importedValue == null;

final importedBarrelMapValue = () => {'key': barrel.importedValue};

final importedBarrelIndexValue = () => {'key': barrel.importedValue}['key'];

final importedBarrelCoalesceValue = () => barrel.importedValue ?? null;

final importedBarrelCompareValue = () => barrel.importedValue == null;
