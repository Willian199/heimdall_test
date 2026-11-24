import '../support.dart' show typeOfValue;
import 'facade.dart';

class Subject extends Model<int> with Inspect {}

Type nativeType() => Subject().inferred;
