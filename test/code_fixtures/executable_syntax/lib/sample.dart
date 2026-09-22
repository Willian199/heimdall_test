import 'package:widgets/widgets.dart' as ui;

void topLevel() {
  print('top');
}

class Sample {
  final int stable = 1;
  static const int constant = 2;
  late final int lazy;
  int mutable = 0;
  int? first, second;
  String? label;
  var inferred = 0;

  Sample() : label = read()!;

  void assertions(String? value) {
    if (value != null) print(value!);
    final closure = () => value!;
    // value! is a comment, and != is not an assertion.
    print('value!');
  }

  void widgets() {
    Divider(color: Colors.red, height: 1 + 2);
    Divider(height: 1 + 2, color: Colors.red);
    Container();
    Container(child: text);
    ui.Divider(height: 1 + 2, color: Colors.red);
    const Widget.named(label: 'hello world');
    new Widget.named(label: 'hello world');
  }

  void logging() {
    print('hello world');
    logger.print('hello world');
    print('helloworld');
    configure(1, enabled: true, label: 'x');
  }

  void arithmetic() {
    final value = first /* comment */ + second;
  }

  void cascades() {
    logger
      ..print('hello')
      ..Container();
  }

  void methodNamedLikeConstructor(Builder builder) {
    builder.Container();
  }

  void other() {
    final value = first - second;
  }

  void defaults([Object value = const Container()]) {}
  final initialized = Container();

  Sample copyWith({int? first, String? label}) => this;
  List<Object?> get props => [stable, first, this.label];
}

class Builder {
  void Container() {}
}

class Shadowed {
  int value = 0;
  List<Object> get props {
    final value = 1;
    return [value];
  }
}

class OtherReceiver {
  int value = 0;
  List<Object> get props => [other.value];
}

class ExplicitThis {
  int value = 0;
  List<Object> props(int value) => [this.value];
}

class Nested {
  int value = 0;
  List<Object> get props {
    List<Object> nested() => [value];
    final callback = () => [value];
    return [];
  }
}

class BlockReturn {
  int value = 0;
  List<Object> get props {
    return [value];
  }
}

class LaterLocal {
  int value = 0;
  List<Object> props(bool choose) {
    if (choose) return [value];
    final value = 1;
    return [value];
  }
}

class LaterPattern {
  int value = 0;
  List<Object> props(bool choose) {
    if (choose) return [value];
    final (value, _) = (1, 2);
    return [value];
  }
}

class Missing {
  int value = 0;
}

class PatternShadow {
  int value = 0;
  List<Object> get props {
    final (value, _) = (1, 2);
    return [value];
  }
}

class BranchProps {
  int value = 0;
  bool choose = false;
  List<Object> get props => choose ? [value] : [];
}

class CompleteBranchProps {
  int value = 0;
  bool choose = false;
  List<Object> get props => choose ? [value] : [this.value];
}

class UnknownBranchProps {
  int value = 0;
  bool choose = false;
  List<Object> get props => choose ? [value] : other();
  List<Object> other() => [value];
}

class CopyState {
  final String? label;
  final int count;
  CopyState({this.label, required this.count});

  CopyState copyWith({String? label, int? count}) =>
      CopyState(label: label ?? this.label, count: this.count);
  CopyState copyAll({String? label, int? count}) =>
      CopyState(label: label ?? this.label, count: count ?? this.count);
  CopyState copyDirect({String? label, required int count}) =>
      CopyState(label: label, count: count);
  CopyState copyUnused({String? label, int? count}) => this;
  CopyState copyConditional(bool choose, {String? label, int? count}) => choose
      ? CopyState(label: label ?? this.label, count: count ?? this.count)
      : this;
  CopyState copyLoopShadow(int count) {
    for (final count in [1]) {
      return CopyState(label: label, count: count);
    }
    return CopyState(label: label, count: count);
  }
}

class VariantState {
  int? first, second;
  VariantState copyFirst({int? first}) => this;
  VariantState copySecond({int? second}) => this;
  VariantState copyBoth({int? first, int? second}) => this;
  VariantState copyBothAgain({int? first, int? second}) => this;
  List<Object?> get firstProps => [first];
  List<Object?> get secondProps => [second];
  List<Object?> get bothProps => [first, second];
  List<Object?> get alsoBothProps => [this.first, this.second];
}
