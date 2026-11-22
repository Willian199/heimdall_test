import 'dart:async' as async show Future;
import 'dart:collection' as collections hide Queue;
import 'dart:core' as core show List, Future, Stream, Expando, WeakReference, Comparator;
import 'package:collection/src/priority_queue.dart' as priority;
import 'package:collection/collection.dart' as collection;
import 'facade.dart' as sdk;
import 'bounded.dart' as custom;
import 'cycle_a.dart' as cyclic;
import 'conditional.dart' if (dart.library.io) 'dart:async' as conditional;

part 'header.dart';

async.Future direct() => throw 0;
core.List coreList() => throw 0;
core.Future coreReexport() => throw 0;
core.Comparator callback() => throw 0;
sdk.Future throughFacade() => throw 0;
cyclic.Future throughCycle() => throw 0;
conditional.Future throughConditional() => throw 0;
final inferredThroughFacade = sdk.Future.error('failure');

// Deliberately unresolved references: parse-only rules must not guess their type.
async.Stream excludedByShow() => throw 0;
collections.Queue excludedByHide() => throw 0;
async.List wrongLibrary() => throw 0;
sdk.Stream excludedByExport() => throw 0;
core.Queue wrongCoreLibrary() => throw 0;
Future excludedByExplicitCore() => throw 0;

core.Expando boundedSdk() => throw 0;
core.WeakReference boundedSdkReference() => throw 0;
custom.Queue boundedLocal() => throw 0;
custom.Stream nonGenericLocal() => throw 0;
sdk.Future<int> explicitArguments() => throw 0;
Future lexicalShadow<Future>(Future value) => value;
priority.HeapPriorityQueue externalQueue() => throw 0;
collection.HeapPriorityQueue externalReexport() => throw 0;
