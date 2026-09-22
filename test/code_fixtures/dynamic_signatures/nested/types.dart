class Box<T> {}

typedef Identifier = Box<int>;
typedef Payload = Box<dynamic>;
typedef Chain = Payload;
typedef Callback = dynamic Function(int);
typedef dynamic LegacyCallback(int value);
typedef Pair = (String, {dynamic value});
typedef Typed<T> = Box<T>;
typedef AlwaysDynamic<T> = Box<dynamic>;
typedef CycleA = CycleB;
typedef CycleB = CycleA;

class T<V> {}
