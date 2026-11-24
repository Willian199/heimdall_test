import '../cases.dart' show EdgeCase;
import '../support.dart' show typeOf;
import 'homonyms_two_prefixes.dart' as c0;
import 'homonyms_reversed_prefixes.dart' as c1;
import 'homonyms_same_prefix_left.dart' as c2;
import 'homonyms_same_prefix_right.dart' as c3;
import 'homonyms_local_shadows_import.dart' as c4;
import 'homonyms_prefixed_alias.dart' as c5;
import 'homonyms_reexported_declarations.dart' as c6;
import 'homonyms_private_part_alias.dart' as c7;

final List<EdgeCase> cases = [
  (
    name: "homonyms_two_prefixes",
    file: "homonyms/homonyms_two_prefixes.dart",
    actual: c0.nativeType,
    expected: typeOf<(int, dynamic)>(),
    findings: ["DynamicSubject has public dynamic supertype or extension target: right.Inspect"],
  ),
  (
    name: "homonyms_reversed_prefixes",
    file: "homonyms/homonyms_reversed_prefixes.dart",
    actual: c1.nativeType,
    expected: typeOf<(dynamic, int)>(),
    findings: ["DynamicSubject has public dynamic supertype or extension target: first.Inspect"],
  ),
  (name: "homonyms_same_prefix_left", file: "homonyms/homonyms_same_prefix_left.dart", actual: c2.nativeType, expected: typeOf<int>(), findings: []),
  (
    name: "homonyms_same_prefix_right",
    file: "homonyms/homonyms_same_prefix_right.dart",
    actual: c3.nativeType,
    expected: typeOf<dynamic>(),
    findings: ["Subject has public dynamic supertype or extension target: p.Inspect"],
  ),
  (
    name: "homonyms_local_shadows_import",
    file: "homonyms/homonyms_local_shadows_import.dart",
    actual: c4.nativeType,
    expected: typeOf<int>(),
    findings: [],
  ),
  (
    name: "homonyms_prefixed_alias",
    file: "homonyms/homonyms_prefixed_alias.dart",
    actual: c5.nativeType,
    expected: typeOf<dynamic>(),
    findings: ["Subject has public dynamic supertype or extension target: p.Inspect"],
  ),
  (
    name: "homonyms_reexported_declarations",
    file: "homonyms/homonyms_reexported_declarations.dart",
    actual: c6.nativeType,
    expected: typeOf<int>(),
    findings: [],
  ),
  (
    name: "homonyms_private_part_alias",
    file: "homonyms/homonyms_private_part_alias.dart",
    actual: c7.nativeType,
    expected: typeOf<int>(),
    findings: [],
  ),
];
