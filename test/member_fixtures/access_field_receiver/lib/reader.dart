class Other {
  final String name;

  Other(this.name);
}

class Reader {
  final String name;
  final Other other;
  final List<String> entries;
  final List<String> otherNames;

  Reader(this.name, this.other, this.entries, this.otherNames);

  String readOtherName() => other.name;

  int countEntries() {
    var count = 0;
    for (final entries in entries) {
      count += entries.length;
    }
    return count;
  }

  String readNameAfterLoop() {
    for (final name in otherNames) {
      name.length;
    }
    return name;
  }

  String readPattern(Object value) {
    if (value case String name) {
      return name;
    }
    return 'unmatched';
  }

  String catchName() {
    try {
      throw StateError('unavailable');
    } catch (name) {
      return name.toString();
    }
  }
}
