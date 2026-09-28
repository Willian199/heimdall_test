class Future {
  static int sync(int Function() callback) => callback();
}

class List {
  List.from(Iterable<Object?> values);
}

final safeLocalFuture = () => Future.sync(() => 1);
final safeLocalList = () => List.from(<dynamic>[]);
