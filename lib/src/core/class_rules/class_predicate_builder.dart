import 'package:heimdall_test/heimdall_test.dart';

/// Fluent predicate builder for class and type declaration rules.
///
/// Each predicate narrows the declarations that the later condition chain will
/// validate. The default selection is every imported type declaration.
final class ClassPredicateBuilder implements HeimdallPredicateBuilder<CompilationUnitMember, ClassPredicateBuilder, ClassShouldBuilder> {
  /// Creates a class predicate builder.
  ClassPredicateBuilder({required this.inverted});

  /// Whether generated rules should invert their final condition.
  final bool inverted;
  HeimdallPredicate<CompilationUnitMember> _predicate = alwaysClass;
  bool _useOr = false;
  bool _negateNext = false;

  @override
  ClassPredicateBuilder and() {
    _useOr = false;
    return this;
  }

  @override
  ClassPredicateBuilder or() {
    _useOr = true;
    return this;
  }

  @override
  ClassPredicateBuilder not() {
    assert(!_negateNext, 'not() called twice in sequence');
    _negateNext = true;
    return this;
  }

  @override
  ClassShouldBuilder should() {
    return ClassShouldBuilder(predicate: _predicate, inverted: inverted);
  }

  @override
  ClassPredicateBuilder satisfy(
    HeimdallPredicate<CompilationUnitMember> predicate,
  ) {
    final nextPredicate = _negateNext ? predicate.not() : predicate;
    _predicate = _predicate == alwaysClass && !_useOr ? nextPredicate : (_useOr ? _predicate.or(nextPredicate) : _predicate.and(nextPredicate));
    _useOr = false;
    _negateNext = false;
    return this;
  }

  /// Selects public type declarations.
  ClassPredicateBuilder arePublic() => satisfy(HeimdallPredicate('are public', (item, _) => item.isPublic));

  /// Selects private type declarations.
  ClassPredicateBuilder arePrivate() => satisfy(HeimdallPredicate('are private', (item, _) => item.isPrivate));

  /// Selects final classes.
  ClassPredicateBuilder areFinal() => satisfy(HeimdallPredicate('are final', (item, _) => item.isFinal));

  /// Selects abstract classes.
  ClassPredicateBuilder areAbstract() => satisfy(HeimdallPredicate('are abstract', (item, _) => item.isAbstract));

  /// Selects enums.
  ClassPredicateBuilder areEnums() => satisfy(HeimdallPredicate('are enums', (item, _) => item.isEnum));

  /// Selects mixins.
  ClassPredicateBuilder areMixins() => satisfy(HeimdallPredicate('are mixins', (item, _) => item.isMixin));

  /// Selects sealed classes.
  ClassPredicateBuilder areSealed() => satisfy(HeimdallPredicate('are sealed', (item, _) => item.isSealed));

  /// Selects base classes or mixins.
  ClassPredicateBuilder areBase() => satisfy(HeimdallPredicate('are base', (item, _) => item.isBase));

  /// Selects interface classes.
  ClassPredicateBuilder areInterfaces() => satisfy(HeimdallPredicate('are interfaces', (item, _) => item.isInterface));

  /// Selects extension types.
  ClassPredicateBuilder areExtensionTypes() => satisfy(HeimdallPredicate('are extension types', (item, _) => item.isExtensionType));

  /// Predicate that accepts every type declaration.
  static const alwaysClass = HeimdallPredicate<CompilationUnitMember>(
    'all classes',
    _alwaysDeclarationPredicate,
  );

  static bool _alwaysDeclarationPredicate(
    CompilationUnitMember _,
    HeimdallProject project,
  ) => true;
}
