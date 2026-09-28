typedef IdentityA = T Function<T>(T);
typedef IdentityB = U Function<U>(U);

IdentityA identityFromB(IdentityB value) => value;

class GenericCallbacks {
  late final T Function<T>(T) identity;
}
