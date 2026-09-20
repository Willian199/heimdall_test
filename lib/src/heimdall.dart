import 'package:heimdall_test/src/core/class_rules/class_rules.dart';
import 'package:heimdall_test/src/core/file_rules/file_rules.dart';
import 'package:heimdall_test/src/core/member_rules/member_rules.dart';
import 'package:heimdall_test/src/library/code_sight.dart';
import 'package:heimdall_test/src/library/dependency_sight.dart';
import 'package:heimdall_test/src/library/layers.dart';
import 'package:heimdall_test/src/library/slices.dart';

/// Entry point for Heimdall's fluent rule DSL.
///
/// Each static method chooses the initial rule scope. Use `.that()` to narrow
/// the selected items, `.should()` to add assertions, and `.check(project)` to
/// execute the rule against an imported `HeimdallProject`.
final class Heimdall {
  const Heimdall._();

  /// Starts a rule over all imported Dart type declarations.
  ///
  /// The scope includes classes, enums, mixins, extensions, and extension types.
  static ClassRules classes() => const ClassRules(inverted: false);

  /// Starts a rule where selected type declarations must not satisfy conditions.
  ///
  /// For example, `Heimdall.noClasses().that().resideInPath('data').should()
  /// .haveTypeNameEndingWith('Dto')` fails for every selected declaration in
  /// `data` whose name ends with `Dto`.
  static ClassRules noClasses() => const ClassRules(inverted: true);

  /// Starts a rule over imported source files.
  static FileRules files() => const FileRules(inverted: false);

  /// Starts a rule where selected files must not satisfy conditions.
  static FileRules noFiles() => const FileRules(inverted: true);

  /// Starts a rule over all members declared by imported type declarations.
  ///
  /// The scope includes fields, methods, and constructors.
  static MemberRules members() => const MemberRules(
    inverted: false,
    selection: MemberSelection.members,
  );

  /// Starts a rule where selected members must not satisfy conditions.
  static MemberRules noMembers() => const MemberRules(
    inverted: true,
    selection: MemberSelection.members,
  );

  /// Starts a rule over fields.
  static MemberRules fields() => const MemberRules(
    inverted: false,
    selection: MemberSelection.fields,
  );

  /// Starts a rule where selected fields must not satisfy conditions.
  static MemberRules noFields() => const MemberRules(
    inverted: true,
    selection: MemberSelection.fields,
  );

  /// Starts a rule over methods.
  static MemberRules methods() => const MemberRules(
    inverted: false,
    selection: MemberSelection.methods,
  );

  /// Starts a rule where selected methods must not satisfy conditions.
  static MemberRules noMethods() => const MemberRules(
    inverted: true,
    selection: MemberSelection.methods,
  );

  /// Starts a rule over constructors.
  static MemberRules constructors() => const MemberRules(
    inverted: false,
    selection: MemberSelection.constructors,
  );

  /// Starts a rule where selected constructors must not satisfy conditions.
  static MemberRules noConstructors() => const MemberRules(
    inverted: true,
    selection: MemberSelection.constructors,
  );

  /// Starts a rule over executable members, meaning methods and constructors.
  static MemberRules codeUnits() => const MemberRules(
    inverted: false,
    selection: MemberSelection.codeUnits,
  );

  /// Starts a rule where selected executable members must not satisfy conditions.
  static MemberRules noCodeUnits() => const MemberRules(
    inverted: true,
    selection: MemberSelection.codeUnits,
  );

  /// Built-in source-code quality rules.
  static HeimdallCodeSight code() => const HeimdallCodeSight();

  /// Built-in dependency rules.
  static HeimdallDependencySight dependencies() => const HeimdallDependencySight();

  /// Creates a layer architecture rule builder.
  static HeimdallLayers layers() => HeimdallLayers();

  /// Creates a slice rule builder using [pattern] to identify slice names.
  ///
  /// The pattern must contain `(*)`, which captures one path segment as the
  /// slice name.
  static HeimdallSlices slices(String pattern) => HeimdallSlices.matching(pattern);
}
