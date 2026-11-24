import '../support.dart' show typeOfValue;
import 'left.dart' as left;
import 'right.dart' as right;

class TypedSubject extends left.Model<int> with left.Inspect {}

class DynamicSubject extends right.Model<int> with right.Inspect {}

Type nativeType() => typeOfValue((TypedSubject().read(), DynamicSubject().read()));
