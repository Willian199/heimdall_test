import 'dart:collection';

import 'package:collection/collection.dart';

import '../b/model.dart';

class Consumer extends ListBase<int> {
  Consumer(this.model);

  final Model model;
  final queue = HeapPriorityQueue<int>();
  final _values = <int>[];

  @override
  int get length => _values.length;

  @override
  set length(int value) => _values.length = value;

  @override
  int operator [](int index) => _values[index];

  @override
  void operator []=(int index, int value) => _values[index] = value;
}
