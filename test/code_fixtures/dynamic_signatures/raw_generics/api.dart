import 'dart:async';
import 'dart:collection';
import 'dart:core';
import 'dart:core' as core;
import 'package:missing/http.dart' as http;
import 'package:missing/other.dart' as other;
import 'package:missing/widgets.dart';

Future future() => throw 0;
Stream? stream() => throw 0;
FutureOr futureOr() => throw 0;
Completer completer() => throw 0;
StreamSubscription subscription() => throw 0;
StreamController controller() => throw 0;
core.List? list() => throw 0;
Map map() => throw 0;
Set set() => throw 0;
Iterable iterable() => throw 0;
Queue queue() => throw 0;
Future<List<Stream>> nested() => throw 0;
void accept(Future? value) {}

http.Response? response() => throw 0;
other.Response otherResponse() => throw 0;
ValueNotifier notifier() => throw 0;
ValueListenable? listenable() => throw 0;

Future<void> safeFuture() => throw 0;
Stream<int>? safeStream() => throw 0;
core.List<String> safeList() => throw 0;
other.List externalList() => throw 0;
http.Response<String> safeResponse() => throw 0;
Expando safeBound() => throw 0;
WeakReference safeWeakReference() => throw 0;
Future shadowed<Future>(Future value) => value;
Response externalShadowed<Response>(Response value) => value;
