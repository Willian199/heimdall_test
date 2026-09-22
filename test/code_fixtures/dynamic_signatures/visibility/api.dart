import 'barrel.dart' as visible;
import 'barrel.dart' as hidden hide Box;
import 'hidden.dart' as exported;
import 'barrel.dart' show Plain;

visible.Box raw() => throw 0;
visible.Alias alias() => throw 0;
visible.Box<int> typed() => throw 0;
visible.Plain plain() => throw 0;
hidden.Box hiddenImport() => throw 0;
exported.Box hiddenExport() => throw 0;
Box excludedByShow() => throw 0;
