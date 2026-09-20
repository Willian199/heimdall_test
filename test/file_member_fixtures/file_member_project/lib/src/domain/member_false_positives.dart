class MemberFalsePositives {
  final String name = 'declared only';

  void save() {}

  String readLocalName() {
    final name = 'local only';
    return name;
  }

  String readNestedLocalName() {
    final reader = () {
      final name = 'nested local only';
      return name;
    };
    return reader();
  }

  MemberFalsePositives();
}
