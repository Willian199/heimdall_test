import '../cases.dart' show EdgeCase;
import 'support.dart';
import 'empty_later_mixin_typed.dart' as c0;
import 'empty_later_override_typed.dart' as c1;
import 'getter_preserves_method_typed.dart' as c2;
import 'method_preserves_getter_typed.dart' as c3;
import 'interface_refines_return_typed.dart' as c4;
import 'interface_parameter_contravariance_typed.dart' as c5;
import 'interface_setter_contravariance_typed.dart' as c6;
import 'repeated_formal_typed.dart' as c7;
import 'private_on_constraint_typed.dart' as c8;
import 'explicit_top_bound_default_typed.dart' as c9;
import 'generic_binder_alpha_typed.dart' as c10;
import 'generic_named_bound_typed.dart' as c11;
import 'generic_optional_binder_typed.dart' as c12;
import 'enum_prior_interface_typed.dart' as c13;
import 'nullable_literal_collection_typed.dart' as c14;
import 'nullable_mixin_collection_getter_typed.dart' as c15;
import 'nullable_inferred_future_typed.dart' as c16;
import 'nullable_explicit_future_typed.dart' as c17;
import 'nullable_inferred_stream_typed.dart' as c18;
import 'nullable_record_components_typed.dart' as c19;
import 'nullable_function_components_typed.dart' as c20;
import 'nullable_nested_generic_container_typed.dart' as c21;
import 'empty_later_mixin_dynamic.dart' as c22;
import 'empty_later_override_dynamic.dart' as c23;
import 'getter_preserves_method_dynamic.dart' as c24;
import 'method_preserves_getter_dynamic.dart' as c25;
import 'interface_refines_return_dynamic.dart' as c26;
import 'interface_parameter_contravariance_dynamic.dart' as c27;
import 'interface_setter_contravariance_dynamic.dart' as c28;
import 'repeated_formal_dynamic.dart' as c29;
import 'private_on_constraint_dynamic.dart' as c30;
import 'explicit_top_bound_default_dynamic.dart' as c31;
import 'generic_binder_alpha_dynamic.dart' as c32;
import 'generic_named_bound_dynamic.dart' as c33;
import 'generic_optional_binder_dynamic.dart' as c34;
import 'enum_prior_interface_dynamic.dart' as c35;
import 'nullable_literal_collection_dynamic.dart' as c36;
import 'nullable_mixin_collection_getter_dynamic.dart' as c37;
import 'nullable_inferred_future_dynamic.dart' as c38;
import 'nullable_explicit_future_dynamic.dart' as c39;
import 'nullable_inferred_stream_dynamic.dart' as c40;
import 'nullable_record_components_dynamic.dart' as c41;
import 'nullable_function_components_dynamic.dart' as c42;
import 'nullable_nested_generic_container_dynamic.dart' as c43;
import 'phantom_alias_erases_constraint.dart' as c44;
import 'alias_discards_second_formal.dart' as c45;

final List<EdgeCase> cases = [
  (name: "empty_later_mixin_typed", file: "additional/empty_later_mixin_typed.dart", actual: c0.nativeType, expected: typeOf<int>(), findings: []),
  (
    name: "empty_later_override_typed",
    file: "additional/empty_later_override_typed.dart",
    actual: c1.nativeType,
    expected: typeOf<int>(),
    findings: [],
  ),
  (
    name: "getter_preserves_method_typed",
    file: "additional/getter_preserves_method_typed.dart",
    actual: c2.nativeType,
    expected: typeOf<int>(),
    findings: [],
  ),
  (
    name: "method_preserves_getter_typed",
    file: "additional/method_preserves_getter_typed.dart",
    actual: c3.nativeType,
    expected: typeOf<int>(),
    findings: [],
  ),
  (
    name: "interface_refines_return_typed",
    file: "additional/interface_refines_return_typed.dart",
    actual: c4.nativeType,
    expected: typeOf<int>(),
    findings: [],
  ),
  (
    name: "interface_parameter_contravariance_typed",
    file: "additional/interface_parameter_contravariance_typed.dart",
    actual: c5.nativeType,
    expected: typeOf<int>(),
    findings: [],
  ),
  (
    name: "interface_setter_contravariance_typed",
    file: "additional/interface_setter_contravariance_typed.dart",
    actual: c6.nativeType,
    expected: typeOf<int>(),
    findings: [],
  ),
  (name: "repeated_formal_typed", file: "additional/repeated_formal_typed.dart", actual: c7.nativeType, expected: typeOf<int>(), findings: []),
  (
    name: "private_on_constraint_typed",
    file: "additional/private_on_constraint_typed.dart",
    actual: c8.nativeType,
    expected: typeOf<int>(),
    findings: [],
  ),
  (
    name: "explicit_top_bound_default_typed",
    file: "additional/explicit_top_bound_default_typed.dart",
    actual: c9.nativeType,
    expected: typeOf<Object?>(),
    findings: [],
  ),
  (
    name: "generic_binder_alpha_typed",
    file: "additional/generic_binder_alpha_typed.dart",
    actual: c10.nativeType,
    expected: typeOf<int>(),
    findings: [],
  ),
  (
    name: "generic_named_bound_typed",
    file: "additional/generic_named_bound_typed.dart",
    actual: c11.nativeType,
    expected: typeOf<int>(),
    findings: [],
  ),
  (
    name: "generic_optional_binder_typed",
    file: "additional/generic_optional_binder_typed.dart",
    actual: c12.nativeType,
    expected: typeOf<int>(),
    findings: [],
  ),
  (
    name: "enum_prior_interface_typed",
    file: "additional/enum_prior_interface_typed.dart",
    actual: c13.nativeType,
    expected: typeOf<int>(),
    findings: [],
  ),
  (
    name: "nullable_literal_collection_typed",
    file: "additional/nullable_literal_collection_typed.dart",
    actual: c14.nativeType,
    expected: typeOf<List<int>>(),
    findings: [],
  ),
  (
    name: "nullable_mixin_collection_getter_typed",
    file: "additional/nullable_mixin_collection_getter_typed.dart",
    actual: c15.nativeType,
    expected: typeOf<List<int>>(),
    findings: [],
  ),
  (
    name: "nullable_inferred_future_typed",
    file: "additional/nullable_inferred_future_typed.dart",
    actual: c16.nativeType,
    expected: typeOf<Future<int>>(),
    findings: [],
  ),
  (
    name: "nullable_explicit_future_typed",
    file: "additional/nullable_explicit_future_typed.dart",
    actual: c17.nativeType,
    expected: typeOf<Future<int>>(),
    findings: [],
  ),
  (
    name: "nullable_inferred_stream_typed",
    file: "additional/nullable_inferred_stream_typed.dart",
    actual: c18.nativeType,
    expected: typeOf<Stream<int>>(),
    findings: [],
  ),
  (
    name: "nullable_record_components_typed",
    file: "additional/nullable_record_components_typed.dart",
    actual: c19.nativeType,
    expected: typeOf<(int, String)>(),
    findings: [],
  ),
  (
    name: "nullable_function_components_typed",
    file: "additional/nullable_function_components_typed.dart",
    actual: c20.nativeType,
    expected: typeOf<int Function()>(),
    findings: [],
  ),
  (
    name: "nullable_nested_generic_container_typed",
    file: "additional/nullable_nested_generic_container_typed.dart",
    actual: c21.nativeType,
    expected: typeOf<List<int>>(),
    findings: [],
  ),
  (
    name: "empty_later_mixin_dynamic",
    file: "additional/empty_later_mixin_dynamic.dart",
    actual: c22.nativeType,
    expected: typeOf<dynamic>(),
    findings: [
      "Subject has public dynamic supertype or extension target: WideBase<dynamic>",
      "Subject has public dynamic supertype or extension target: Refine",
      "Subject has public dynamic supertype or extension target: Empty",
      "result has public dynamic type",
    ],
  ),
  (
    name: "empty_later_override_dynamic",
    file: "additional/empty_later_override_dynamic.dart",
    actual: c23.nativeType,
    expected: typeOf<dynamic>(),
    findings: [
      "Subject has public dynamic supertype or extension target: WideBase<dynamic>",
      "Subject has public dynamic supertype or extension target: Refine",
      "Subject has public dynamic supertype or extension target: Empty",
      "read has public dynamic return type",
      "result has public dynamic type",
    ],
  ),
  (
    name: "getter_preserves_method_dynamic",
    file: "additional/getter_preserves_method_dynamic.dart",
    actual: c24.nativeType,
    expected: typeOf<dynamic>(),
    findings: [
      "Subject has public dynamic supertype or extension target: WideBase<dynamic>",
      "Subject has public dynamic supertype or extension target: MethodOnly",
      "Subject has public dynamic supertype or extension target: GetterOnly",
      "result has public dynamic type",
    ],
  ),
  (
    name: "method_preserves_getter_dynamic",
    file: "additional/method_preserves_getter_dynamic.dart",
    actual: c25.nativeType,
    expected: typeOf<dynamic>(),
    findings: [
      "Subject has public dynamic supertype or extension target: WideBase<dynamic>",
      "Subject has public dynamic supertype or extension target: MethodOnly",
      "Subject has public dynamic supertype or extension target: GetterOnly",
      "result has public dynamic type",
    ],
  ),
  (
    name: "interface_refines_return_dynamic",
    file: "additional/interface_refines_return_dynamic.dart",
    actual: c26.nativeType,
    expected: typeOf<dynamic>(),
    findings: [
      "Subject has public dynamic supertype or extension target: ReadContract<dynamic>",
      "read has public dynamic return type",
      "result has public dynamic type",
    ],
  ),
  (
    name: "interface_parameter_contravariance_dynamic",
    file: "additional/interface_parameter_contravariance_dynamic.dart",
    actual: c27.nativeType,
    expected: typeOf<dynamic>(),
    findings: ["Subject has public dynamic supertype or extension target: AcceptContract<dynamic>", "accept has public dynamic parameter next"],
  ),
  (
    name: "interface_setter_contravariance_dynamic",
    file: "additional/interface_setter_contravariance_dynamic.dart",
    actual: c28.nativeType,
    expected: typeOf<dynamic>(),
    findings: ["Subject has public dynamic supertype or extension target: WriteContract<dynamic>", "output has public dynamic parameter next"],
  ),
  (
    name: "repeated_formal_dynamic",
    file: "additional/repeated_formal_dynamic.dart",
    actual: c29.nativeType,
    expected: typeOf<dynamic>(),
    findings: [
      "Subject has public dynamic supertype or extension target: HeaderBox<Repeated<dynamic, dynamic>>",
      "Subject has public dynamic supertype or extension target: RepeatedAccess",
    ],
  ),
  (
    name: "private_on_constraint_dynamic",
    file: "additional/private_on_constraint_dynamic.dart",
    actual: c30.nativeType,
    expected: typeOf<dynamic>(),
    findings: [
      "Subject has public dynamic supertype or extension target: PublicPrivate<dynamic>",
      "Subject has public dynamic supertype or extension target: PrivateAccess",
    ],
  ),
  (
    name: "explicit_top_bound_default_dynamic",
    file: "additional/explicit_top_bound_default_dynamic.dart",
    actual: c31.nativeType,
    expected: typeOf<Object?>(),
    findings: [
      "Subject has public dynamic supertype or extension target: HeaderBox<dynamic>",
      "Subject has public dynamic supertype or extension target: TopDefault",
    ],
  ),
  (
    name: "generic_binder_alpha_dynamic",
    file: "additional/generic_binder_alpha_dynamic.dart",
    actual: c32.nativeType,
    expected: typeOf<dynamic>(),
    findings: [
      "Subject has public dynamic supertype or extension target: HeaderBox<dynamic Function<X>(X)>",
      "Subject has public dynamic supertype or extension target: GenericClosure",
    ],
  ),
  (
    name: "generic_named_bound_dynamic",
    file: "additional/generic_named_bound_dynamic.dart",
    actual: c33.nativeType,
    expected: typeOf<dynamic>(),
    findings: [
      "Subject has public dynamic supertype or extension target: HeaderBox<dynamic Function<X extends num>({required X value})>",
      "Subject has public dynamic supertype or extension target: NamedClosure",
    ],
  ),
  (
    name: "generic_optional_binder_dynamic",
    file: "additional/generic_optional_binder_dynamic.dart",
    actual: c34.nativeType,
    expected: typeOf<dynamic>(),
    findings: [
      "Subject has public dynamic supertype or extension target: HeaderBox<dynamic Function<X>([X? value])>",
      "Subject has public dynamic supertype or extension target: OptionalClosure",
    ],
  ),
  (
    name: "enum_prior_interface_dynamic",
    file: "additional/enum_prior_interface_dynamic.dart",
    actual: c35.nativeType,
    expected: typeOf<dynamic>(),
    findings: [
      "Subject has public dynamic supertype or extension target: Carrier<dynamic>",
      "Subject has public dynamic supertype or extension target: HeaderAccess",
    ],
  ),
  (
    name: "nullable_literal_collection_dynamic",
    file: "additional/nullable_literal_collection_dynamic.dart",
    actual: c36.nativeType,
    expected: typeOf<List<dynamic>>(),
    findings: ["result has public dynamic type"],
  ),
  (
    name: "nullable_mixin_collection_getter_dynamic",
    file: "additional/nullable_mixin_collection_getter_dynamic.dart",
    actual: c37.nativeType,
    expected: typeOf<List<dynamic>>(),
    findings: ["result has public dynamic type"],
  ),
  (
    name: "nullable_inferred_future_dynamic",
    file: "additional/nullable_inferred_future_dynamic.dart",
    actual: c38.nativeType,
    expected: typeOf<Future<dynamic>>(),
    findings: ["result has public dynamic type"],
  ),
  (
    name: "nullable_explicit_future_dynamic",
    file: "additional/nullable_explicit_future_dynamic.dart",
    actual: c39.nativeType,
    expected: typeOf<Future<dynamic>>(),
    findings: ["result has public dynamic type"],
  ),
  (
    name: "nullable_inferred_stream_dynamic",
    file: "additional/nullable_inferred_stream_dynamic.dart",
    actual: c40.nativeType,
    expected: typeOf<Stream<dynamic>>(),
    findings: ["result has public dynamic type"],
  ),
  (
    name: "nullable_record_components_dynamic",
    file: "additional/nullable_record_components_dynamic.dart",
    actual: c41.nativeType,
    expected: typeOf<(dynamic, String)>(),
    findings: ["result has public dynamic type"],
  ),
  (
    name: "nullable_function_components_dynamic",
    file: "additional/nullable_function_components_dynamic.dart",
    actual: c42.nativeType,
    expected: typeOf<dynamic Function()>(),
    findings: ["result has public dynamic type"],
  ),
  (
    name: "nullable_nested_generic_container_dynamic",
    file: "additional/nullable_nested_generic_container_dynamic.dart",
    actual: c43.nativeType,
    expected: typeOf<List<dynamic>>(),
    findings: ["result has public dynamic type"],
  ),
  (
    name: "phantom_alias_erases_constraint",
    file: "additional/phantom_alias_erases_constraint.dart",
    actual: c44.nativeType,
    expected: typeOf<dynamic>(),
    findings: ["Subject has public dynamic supertype or extension target: PhantomAccess"],
  ),
  (
    name: "alias_discards_second_formal",
    file: "additional/alias_discards_second_formal.dart",
    actual: c45.nativeType,
    expected: typeOf<Captured<int, dynamic>>(),
    findings: ["Subject has public dynamic supertype or extension target: DroppedAccess"],
  ),
];
