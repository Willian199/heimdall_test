class GenericParent<T> {}

typedef ParentAlias<T> = GenericParent<T>;

class ChildThroughAlias extends ParentAlias<int> {}
