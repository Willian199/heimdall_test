import '../../api.dart';

int fromA(int depth) => depth == 0 ? 0 : fromB(depth - 1);
