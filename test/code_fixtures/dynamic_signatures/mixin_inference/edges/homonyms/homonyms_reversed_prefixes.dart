import '../support.dart' show typeOfValue;
import 'right.dart' as first;
import 'left.dart' as second;

class DynamicSubject extends first.Model<int> with first.Inspect {}

class TypedSubject extends second.Model<int> with second.Inspect {}

Type nativeType() => typeOfValue((DynamicSubject().read(), TypedSubject().read()));
