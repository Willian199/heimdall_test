abstract interface class Contract<T> {}

class Root<T> implements Contract<T> {}

class Middle<T> extends Root<T> {}

class Leaf extends Middle<int> {}
