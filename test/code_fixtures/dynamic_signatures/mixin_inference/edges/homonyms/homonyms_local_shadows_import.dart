import '../support.dart' show typeOfValue;
import 'left.dart' as left;
import 'right.dart' show Model, Inspect;

class Model<T> extends left.Model<T> {}

class Subject extends Model<int> with Inspect {}

Type nativeType() => Subject().inferred;
