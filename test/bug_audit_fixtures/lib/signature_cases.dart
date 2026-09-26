List<dynamic> _dynamicItems = [];
Map<dynamic, String> _dynamicKeys = {};
Map<String, dynamic> _dynamicValues = {};

keyCount() => _dynamicKeys.keys.length;
valueCount() => _dynamicValues.values.length;
keyIsEmpty() => _dynamicKeys.keys.isEmpty;
valueIsEmpty() => _dynamicValues.values.isEmpty;
keyIsNotEmpty() => _dynamicKeys.keys.isNotEmpty;
valueIsNotEmpty() => _dynamicValues.values.isNotEmpty;
keyListLength() => _dynamicKeys.keys.toList().length;
valueListLength() => _dynamicValues.values.toList().length;
keyJoined() => _dynamicKeys.keys.join(',');
valueJoined() => _dynamicValues.values.join(',');
keyAny() => _dynamicKeys.keys.any((key) => true);
valueAny() => _dynamicValues.values.any((value) => true);
keyIteratorCanMove() => _dynamicKeys.keys.iterator.moveNext();
valueIteratorCanMove() => _dynamicValues.values.iterator.moveNext();
keyContains() => _dynamicKeys.keys.contains('key');
valueContains() => _dynamicValues.values.contains('value');
keyLengthPlus() => _dynamicKeys.keys.length + 1;
valueLengthPlus() => _dynamicValues.values.length + 1;
keyLengthComparison() => _dynamicKeys.keys.length > 0;
entry() => _dynamicKeys.entries.first;

itemsAsList() => _dynamicItems.toList();

itemsFiltered() => _dynamicItems.where((item) => true);

itemsMapped() => _dynamicItems.map((item) => item);

itemsAsSet() => _dynamicItems.toSet();

itemsSkipped() => _dynamicItems.skip(1);

itemsTaken() => _dynamicItems.take(1);

itemsFirstWhere() => _dynamicItems.firstWhere((item) => true);

itemsLastWhere() => _dynamicItems.lastWhere((item) => true);

itemsSingleWhere() => _dynamicItems.singleWhere((item) => true);

itemsElementAt() => _dynamicItems.elementAt(0);

itemsRemoveAt() => _dynamicItems.removeAt(0);

itemsRemoveLast() => _dynamicItems.removeLast();

itemsExpanded() => _dynamicItems.expand((item) => [item]);

itemsFollowedBy() => _dynamicItems.followedBy([null]);

itemsGetRange() => _dynamicItems.getRange(0, 1);

itemsSublist() => _dynamicItems.sublist(0, 1);

itemsReversed() => _dynamicItems.reversed;

itemsSkipWhile() => _dynamicItems.skipWhile((item) => false);

itemsTakeWhile() => _dynamicItems.takeWhile((item) => true);

itemsCast() => _dynamicItems.cast<dynamic>();

mapRemove() => _dynamicValues.remove('key');

mapPutIfAbsent() => _dynamicValues.putIfAbsent('key', () => null);

mapCast() => _dynamicValues.cast<String, dynamic>();

mapUpdate() => _dynamicValues.update('key', (_) => null);
