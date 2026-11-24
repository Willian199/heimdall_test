import 'dart:async';
import '../support.dart';
export 'dart:async';
export '../support.dart';

typedef Payload<T> = Future<(String, Map<int, List<T>>)>;

class AsyncCell<T> extends Cell<Payload<T>> with Members {
  AsyncCell(super.value);
}

mixin Deep0<T> on HeaderBox<Future<(String, Map<int, List<T>>)>> {
  Type get inferred => T;
}

mixin Deep1<T> on HeaderBox<Future<(String, {Map<int, List<T>> payload})>> {
  Type get inferred => T;
}

mixin Deep2<T> on HeaderBox<Stream<(int, Future<Map<String, List<T>>>)>> {
  Type get inferred => T;
}

mixin Deep3<T> on HeaderBox<Future<List<(Map<T, Set<String>>, Map<int, List<bool>>)>>> {
  Type get inferred => T;
}

mixin Deep4<T> on HeaderBox<Map<String, Future<(Set<int>, List<Map<bool, T>>)>>> {
  Type get inferred => T;
}

mixin Deep5<T> on HeaderBox<(Future<Map<String, List<T>>>, {Stream<Set<T>> changes})> {
  Type get inferred => T;
}

mixin Deep6<T> on HeaderBox<Future<Map<int, List<(String, T Function())>>>> {
  Type get inferred => T;
}

mixin Deep7<T> on HeaderBox<Future<(String, {Map<int, List<(T, {bool flag})>> payload})>> {
  Type get inferred => T;
}

mixin Deep8<T> on HeaderBox<FutureOr<(String, Map<int, List<T>>)>> {
  Type get inferred => T;
}
