import 'package:collection/collection.dart';

import 'other_types.dart' as other;
import 'types.dart';

mixin QueueLogging<T> on HeapPriorityQueue<T> {
  Type get elementType => T;
}

class QueueCounter extends HeapPriorityQueue<int> with QueueLogging {}
class DynamicQueueBase extends HeapPriorityQueue<dynamic> {}
class DynamicQueue extends DynamicQueueBase with QueueLogging {}
class Shadowed extends other.Base<int, String> with Logging {}
