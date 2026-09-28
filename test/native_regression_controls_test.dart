// Compile the actual regression fixtures, independently of Heimdall's parser.
// ignore_for_file: avoid_relative_lib_imports
// Explicit assignment targets verify static type compatibility.
// ignore_for_file: omit_local_variable_types

import 'package:test/test.dart';

import 'cascade_field_access_fixtures/lib/reader.dart' as cascade;
import 'constructor_tearoff_call_fixtures/lib/calls.dart' as constructors;
import 'enum_mixin_field_fixtures/lib/status.dart' as enums;
import 'extension_object_assignability_fixtures/lib/value.dart' as objects;
import 'extension_primary_parameter_fixtures/lib/value.dart' as primary;
import 'extension_representation_shadow_fixtures/lib/calls.dart' as shadow;
import 'extension_type_parameter_bound_fixtures/lib/number_box.dart' as bounds;
import 'finally_returned_list_fixtures/lib/props.dart' as returns;
import 'generic_alias_relationship_fixtures/lib/alias_superclass.dart' as aliases;
import 'generic_function_alpha_fixtures/lib/callbacks.dart' as functions;
import 'never_nullable_assignability_fixtures/lib/values.dart' as nullable;
import 'qualified_alias_substitution_fixtures/lib/holder.dart' as qualified;
import 'qualified_alias_substitution_fixtures/lib/types.dart' as types;
import 'relationship_gap_fixtures/lib/generic_inheritance.dart' as hierarchy;
import 'sdk_int64_assignability_fixtures/lib/typed_data.dart' as sdk;

void main() {
  test('Dart executes cascades, constructor tear-offs and enum mixin getters', () {
    final reader = cascade.Reader()..writeThroughCascade();
    expect(reader.value, 3);
    expect(constructors.FactoryCalls().throughTearOff(), isA<constructors.Product>());
    expect(enums.Status.active.readShared(), 0);
  });

  test('Dart accepts extension primary parameters, bounds and representation shadowing', () {
    expect(primary.UserId('id').value, 'id');
    bounds.NumberBox<int>(1).accepts(2);
    shadow.Example(shadow.Thing()).call();
    final Object object = objects.ObjectName('name');
    expect(object, 'name');
  });

  test('Dart replaces the try return with the finally return', () {
    final instance = returns.FinallyOverridesReturn();
    expect(instance.props(), [instance.value]);
  });

  test('Dart preserves instantiated superclass, interface and alias types', () {
    final hierarchy.Root<int> parent = hierarchy.Leaf();
    final hierarchy.Contract<int> contract = hierarchy.Leaf();
    final aliases.GenericParent<int> aliasParent = aliases.ChildThroughAlias();
    final qualified.Alias<int> value = types.Value();
    final types.Value unwrapped = value;
    expect(parent, isA<hierarchy.Root<int>>());
    expect(contract, isA<hierarchy.Contract<int>>());
    expect(aliasParent, isA<aliases.GenericParent<int>>());
    expect(unwrapped, same(value));
  });

  test('Dart compares generic function binders independently of their names', () {
    T identity<T>(T value) => value;
    final functions.IdentityB other = identity;
    final functions.IdentityA converted = functions.identityFromB(other);
    expect(converted<int>(4), 4);
    expect(converted<String>('ok'), 'ok');
  });

  test('Dart treats Never? as Null and 64-bit arrays as List<int>', () {
    expect(nullable.acceptNullableString(null), isNull);
    final fields = sdk.TypedDataFields();
    final List<int> signed = fields.signedValues;
    final List<int> unsigned = fields.unsignedValues;
    expect(signed, isEmpty);
    expect(unsigned, isEmpty);
  });
}
