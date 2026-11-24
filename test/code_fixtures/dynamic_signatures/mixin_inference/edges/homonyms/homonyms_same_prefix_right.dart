import '../support.dart' show typeOfValue;
import 'right.dart' as p;

class Subject extends p.Model<int> with p.Inspect {}

Type nativeType() => Subject().inferred;
