import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/mapper/export.dart';
import 'package:heimdall_test/src/mapper/importer/path_matcher.dart';
import 'package:path/path.dart' as p;

/// Parses one Dart source file and attaches Heimdall context to analyzer nodes.
final class HeimdallSourceFileParser {
  /// Creates a source file parser.
  const HeimdallSourceFileParser();

  /// Parses [file] under [root] using [featureSet].
  HeimdallSourceFile parse(
    String root,
    File file, {
    required FeatureSet featureSet,
  }) {
    final absolutePath = p.normalize(p.absolute(file.path));
    final relativePath = normalizePath(p.relative(absolutePath, from: root));
    final content = file.readAsStringSync();
    final result = parseString(
      content: content,
      path: absolutePath,
      featureSet: featureSet,
      throwIfDiagnostics: false,
    );
    final directives = <Directive>[];
    final declarations = <CompilationUnitMember>[];
    final classMembers = <ClassMember>[];
    final dependencies = <Directive>[];

    for (final directive in result.unit.directives) {
      attachDependencyContext(
        directive: directive,
        originPath: absolutePath,
        lineInfo: result.lineInfo,
      );
      directives.add(directive);
      if (_isDependencyDirective(directive)) {
        dependencies.add(directive);
      }
    }

    for (final member in result.unit.declarations) {
      attachDeclarationContext(
        node: member,
        sourcePath: absolutePath,
        relativePath: relativePath,
        lineInfo: result.lineInfo,
      );
      for (final classMember in _classMembersOf(member)) {
        classMembers.add(classMember);
        attachMemberContext(
          node: classMember,
          owner: member,
          sourcePath: absolutePath,
          relativePath: relativePath,
          lineInfo: result.lineInfo,
        );
      }
      declarations.add(member);
    }

    return HeimdallSourceFile(
      absolutePath: absolutePath,
      relativePath: relativePath,
      content: content,
      directives: directives,
      declarations: declarations,
      classMembers: classMembers,
      dependencies: dependencies,
      parseErrors: result.errors.map((error) {
        final location = result.lineInfo.getLocation(error.offset);
        return HeimdallParseError(
          message: error.message,
          line: location.lineNumber,
          column: location.columnNumber,
        );
      }).toList(),
      lineInfo: result.lineInfo,
    );
  }
}

bool _isDependencyDirective(Directive directive) {
  return directive is ImportDirective || directive is ExportDirective || directive is PartDirective || directive is PartOfDirective;
}

Iterable<ClassMember> _classMembersOf(CompilationUnitMember member) {
  return switch (member) {
    ClassDeclaration(:final body) => _membersFromClassBody(body),
    MixinDeclaration(:final body) => body.members,
    EnumDeclaration(:final body) => body.members,
    ExtensionDeclaration(:final body) => body.members,
    ExtensionTypeDeclaration(:final body) => _membersFromClassBody(body),
    _ => const <ClassMember>[],
  };
}

Iterable<ClassMember> _membersFromClassBody(ClassBody body) {
  return switch (body) {
    BlockClassBody(:final members) => members,
    _ => const <ClassMember>[],
  };
}
