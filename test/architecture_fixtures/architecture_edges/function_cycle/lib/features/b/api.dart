import '../a/consumer.dart';

int fromB(int depth) => depth == 0 ? 0 : fromA(depth - 1);
