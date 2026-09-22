import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  final project = const HeimdallFileImporter(useCache: false).importPath('test/file_member_fixtures/return_types');
  final cases =
      <
        ({
          String name,
          bool negative,
          MemberPredicateBuilder Function(MemberPredicateBuilder) select,
          HeimdallRule<ClassMember> Function(MemberShouldBuilder) require,
        })
      >[
        (
          name: 'haveReturnType',
          negative: false,
          select: (b) => b.haveReturnType('String'),
          require: (b) => b.haveReturnType('String'),
        ),
        (
          name: 'notHaveReturnType',
          negative: true,
          select: (b) => b.notHaveReturnType('String'),
          require: (b) => b.notHaveReturnType('String'),
        ),
        (
          name: 'haveReturnTypeEqualToAnyOf',
          negative: false,
          select: (b) => b.haveReturnTypeEqualToAnyOf(['String']),
          require: (b) => b.haveReturnTypeEqualToAnyOf(['String']),
        ),
        (
          name: 'haveReturnTypeEqualToAllOf',
          negative: false,
          select: (b) => b.haveReturnTypeEqualToAllOf(['String']),
          require: (b) => b.haveReturnTypeEqualToAllOf(['String']),
        ),
        (
          name: 'haveReturnTypeEqualToNoneOf',
          negative: true,
          select: (b) => b.haveReturnTypeEqualToNoneOf(['String']),
          require: (b) => b.haveReturnTypeEqualToNoneOf(['String']),
        ),
        (
          name: 'haveReturnTypeNameStartingWith',
          negative: false,
          select: (b) => b.haveReturnTypeNameStartingWith('Str'),
          require: (b) => b.haveReturnTypeNameStartingWith('Str'),
        ),
        (
          name: 'notHaveReturnTypeNameStartingWith',
          negative: true,
          select: (b) => b.notHaveReturnTypeNameStartingWith('Str'),
          require: (b) => b.notHaveReturnTypeNameStartingWith('Str'),
        ),
        (
          name: 'haveReturnTypeNameStartingWithAnyOf',
          negative: false,
          select: (b) => b.haveReturnTypeNameStartingWithAnyOf(['Str']),
          require: (b) => b.haveReturnTypeNameStartingWithAnyOf(['Str']),
        ),
        (
          name: 'haveReturnTypeNameStartingWithAllOf',
          negative: false,
          select: (b) => b.haveReturnTypeNameStartingWithAllOf(['Str']),
          require: (b) => b.haveReturnTypeNameStartingWithAllOf(['Str']),
        ),
        (
          name: 'haveReturnTypeNameStartingWithNoneOf',
          negative: true,
          select: (b) => b.haveReturnTypeNameStartingWithNoneOf(['Str']),
          require: (b) => b.haveReturnTypeNameStartingWithNoneOf(['Str']),
        ),
        (
          name: 'haveReturnTypeNameEndingWith',
          negative: false,
          select: (b) => b.haveReturnTypeNameEndingWith('ing'),
          require: (b) => b.haveReturnTypeNameEndingWith('ing'),
        ),
        (
          name: 'notHaveReturnTypeNameEndingWith',
          negative: true,
          select: (b) => b.notHaveReturnTypeNameEndingWith('ing'),
          require: (b) => b.notHaveReturnTypeNameEndingWith('ing'),
        ),
        (
          name: 'haveReturnTypeNameEndingWithAnyOf',
          negative: false,
          select: (b) => b.haveReturnTypeNameEndingWithAnyOf(['ing']),
          require: (b) => b.haveReturnTypeNameEndingWithAnyOf(['ing']),
        ),
        (
          name: 'haveReturnTypeNameEndingWithAllOf',
          negative: false,
          select: (b) => b.haveReturnTypeNameEndingWithAllOf(['ing']),
          require: (b) => b.haveReturnTypeNameEndingWithAllOf(['ing']),
        ),
        (
          name: 'haveReturnTypeNameEndingWithNoneOf',
          negative: true,
          select: (b) => b.haveReturnTypeNameEndingWithNoneOf(['ing']),
          require: (b) => b.haveReturnTypeNameEndingWithNoneOf(['ing']),
        ),
        (
          name: 'haveReturnTypeNameMatching',
          negative: false,
          select: (b) => b.haveReturnTypeNameMatching(RegExp(r'^String$')),
          require: (b) => b.haveReturnTypeNameMatching(RegExp(r'^String$')),
        ),
        (
          name: 'notHaveReturnTypeNameMatching',
          negative: true,
          select: (b) => b.notHaveReturnTypeNameMatching(RegExp(r'^String$')),
          require: (b) => b.notHaveReturnTypeNameMatching(RegExp(r'^String$')),
        ),
        (
          name: 'haveReturnTypeNameMatchingAnyOf',
          negative: false,
          select: (b) => b.haveReturnTypeNameMatchingAnyOf([RegExp(r'^String$')]),
          require: (b) => b.haveReturnTypeNameMatchingAnyOf([RegExp(r'^String$')]),
        ),
        (
          name: 'haveReturnTypeNameMatchingAllOf',
          negative: false,
          select: (b) => b.haveReturnTypeNameMatchingAllOf([RegExp(r'^String$')]),
          require: (b) => b.haveReturnTypeNameMatchingAllOf([RegExp(r'^String$')]),
        ),
        (
          name: 'haveReturnTypeNameMatchingNoneOf',
          negative: true,
          select: (b) => b.haveReturnTypeNameMatchingNoneOf([RegExp(r'^String$')]),
          require: (b) => b.haveReturnTypeNameMatchingNoneOf([RegExp(r'^String$')]),
        ),
      ];
  for (final rule in cases) {
    test('${rule.name} separates return types from fields in predicates and conditions', () {
      for (final name in ['text', 'read', 'label', 'count', 'inferred', 'new']) {
        final matches = name == 'read' || name == 'label';
        final expected = rule.negative ? !matches : matches;
        final selected = rule.select(Heimdall.members().that().haveName(name).and()).should().haveName(name).allowEmpty().check(project);
        expect(selected.checkedCount, expected ? 1 : 0, reason: name);
        final checked = rule.require(Heimdall.members().that().haveName(name).should()).check(project);
        expect(checked.checkedCount, 1, reason: name);
        expect(checked.hasFindings, !expected, reason: name);
      }
    });
  }
  test('field family accepts only field types, including collection and pattern rules', () {
    Heimdall.fields().that().haveName('text').should().haveDeclaredFieldTypeName('String').check(project).assertNoFindings();
    final methods = Heimdall.methods().that().haveName('read');
    expect(methods.should().haveDeclaredFieldTypeName('String').check(project).hasFindings, isTrue);
    expect(methods.should().haveDeclaredFieldTypeNameStartingWith('Str').check(project).hasFindings, isTrue);
    expect(methods.should().haveDeclaredFieldTypeNameEndingWith('ing').check(project).hasFindings, isTrue);
    expect(methods.should().haveDeclaredFieldTypeNameMatching(RegExp('String')).check(project).hasFindings, isTrue);
    expect(methods.should().haveDeclaredFieldTypeNameEqualToAnyOf(['String']).check(project).hasFindings, isTrue);
  });
  test('return types retain generic arguments and nullability', () {
    Heimdall.methods().that().haveName('values').should().haveReturnType('List<String>?').check(project).assertNoFindings();
    expect(Heimdall.methods().that().haveName('values').should().haveReturnType('List').check(project).hasFindings, isTrue);
  });
}
