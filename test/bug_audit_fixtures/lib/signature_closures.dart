List<dynamic> _dynamicItems = [];
Map<dynamic, String> _dynamicKeys = {};
Map<String, dynamic> _dynamicValues = {};

final keyCount = () => _dynamicKeys.keys.length;
final valueCount = () => _dynamicValues.values.length;
final keyIsEmpty = () => _dynamicKeys.keys.isEmpty;
final valueIsEmpty = () => _dynamicValues.values.isEmpty;
final keyIsNotEmpty = () => _dynamicKeys.keys.isNotEmpty;
final valueIsNotEmpty = () => _dynamicValues.values.isNotEmpty;
final keyListLength = () => _dynamicKeys.keys.toList().length;
final valueListLength = () => _dynamicValues.values.toList().length;
final keyJoined = () => _dynamicKeys.keys.join(',');
final valueJoined = () => _dynamicValues.values.join(',');
final keyAny = () => _dynamicKeys.keys.any((key) => true);
final valueAny = () => _dynamicValues.values.any((value) => true);
final keyIteratorCanMove = () => _dynamicKeys.keys.iterator.moveNext();
final valueIteratorCanMove = () => _dynamicValues.values.iterator.moveNext();
final keyContains = () => _dynamicKeys.keys.contains('key');
final valueContains = () => _dynamicValues.values.contains('value');
final keyLengthPlus = () => _dynamicKeys.keys.length + 1;
final valueLengthPlus = () => _dynamicValues.values.length + 1;
final keyLengthComparison = () => _dynamicKeys.keys.length > 0;
final entry = () => _dynamicKeys.entries.first;

final itemsAsList = () => _dynamicItems.toList();

final itemsFiltered = () => _dynamicItems.where((item) => true);

final itemsMapped = () => _dynamicItems.map((item) => item);

final itemsAsSet = () => _dynamicItems.toSet();

final itemsSkipped = () => _dynamicItems.skip(1);

final itemsTaken = () => _dynamicItems.take(1);

final itemsFirstWhere = () => _dynamicItems.firstWhere((item) => true);

final itemsLastWhere = () => _dynamicItems.lastWhere((item) => true);

final itemsSingleWhere = () => _dynamicItems.singleWhere((item) => true);

final itemsElementAt = () => _dynamicItems.elementAt(0);

final itemsRemoveAt = () => _dynamicItems.removeAt(0);

final itemsRemoveLast = () => _dynamicItems.removeLast();

final itemsExpanded = () => _dynamicItems.expand((item) => [item]);

final itemsFollowedBy = () => _dynamicItems.followedBy([null]);

final itemsGetRange = () => _dynamicItems.getRange(0, 1);

final itemsSublist = () => _dynamicItems.sublist(0, 1);

final itemsReversed = () => _dynamicItems.reversed;

final itemsSkipWhile = () => _dynamicItems.skipWhile((item) => false);

final itemsTakeWhile = () => _dynamicItems.takeWhile((item) => true);

final itemsCast = () => _dynamicItems.cast<dynamic>();

final mapRemove = () => _dynamicValues.remove('key');

final mapPutIfAbsent = () => _dynamicValues.putIfAbsent('key', () => null);

final mapCast = () => _dynamicValues.cast<String, dynamic>();

final mapUpdate = () => _dynamicValues.update('key', (_) => null);
