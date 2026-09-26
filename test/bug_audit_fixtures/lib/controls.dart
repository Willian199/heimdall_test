final List<dynamic> _items = [];
final Map<dynamic, String> _keys = {};
final Map<String, dynamic> _values = {};

final knownMapped = () => _items.map((item) => 1);
final knownExpanded = () => _items.expand((item) => <int>[1]);
final knownCast = () => _items.cast<int>();
final knownMapCast = () => _values.cast<String, int>();
final knownEntryValue = () => _keys.entries.toList().first.value;
final dynamicEntryKey = () => _keys.entries.first.key;
final knownEntryKey = () => _values.entries.first.key;
final dynamicEntryValue = () => _values.entries.first.value;

class LocalCollection<T> {
  int get first => 1;
  List<dynamic> toList() => [];
}

final LocalCollection<dynamic> _local = LocalCollection<dynamic>();
final knownLocalFirst = () => _local.first;
final dynamicLocalList = () => _local.toList();

class GuardElseRead {
  final int value = 1;

  int read(Object input) {
    if (input case final int value when value > 0) {
      return value;
    } else {
      return value;
    }
  }
}
