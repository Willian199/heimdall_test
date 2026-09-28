class RecordTypeNames {
  (int, String) positional = (1, 'one');

  (int,) singlePositional = (1,);

  ({int id, String label}) named = (id: 1, label: 'one');

  (int, String)? nullable;

  (int, (String, bool)) nested = (1, ('one', true));

  List<(int, String)> recordList = [];

  (int, String) get positionalGetter => (1, 'one');

  ({int id, String label}) get namedGetter => (id: 1, label: 'one');

  (int, String)? get nullableGetter => null;

  (int, String) makePositional() => (1, 'one');

  ({int id, String label}) makeNamed() => (id: 1, label: 'one');

  (int, (String, bool)) makeNested() => (1, ('one', true));
}
