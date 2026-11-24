import '../support.dart' show typeOfValue;
import 'left.dart' as left;
import 'right.dart' as right;

class Subject extends left.ModelAlias<int> with right.Inspect {}

Type nativeType() => Subject().inferred;
