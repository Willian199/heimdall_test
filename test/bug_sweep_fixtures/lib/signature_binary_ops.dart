final binaryEqualNull = () {
  dynamic value;
  return value == null;
};

final binaryEqualInt = () {
  dynamic value;
  return value == 1;
};

final binaryNotEqualNull = () {
  dynamic value;
  return value != null;
};

final binaryNotEqualString = () {
  dynamic value;
  return value != 'x';
};

final binaryLessThan = () {
  dynamic value;
  return value < 1;
};

final binaryGreaterThan = () {
  dynamic value;
  return value > 1;
};

final binaryLessThanOrEqual = () {
  dynamic value;
  return value <= 1;
};

final binaryGreaterThanOrEqual = () {
  dynamic value;
  return value >= 1;
};

final binaryEqualityNestedInList = () {
  dynamic value;
  return [value == null].first;
};

final binaryEqualityNestedInRecord = () {
  dynamic value;
  return (value == null,).$1;
};

final binaryEqualityParenthesized = () {
  dynamic value;
  return (value == null);
};

final binaryEqualityNegated = () {
  dynamic value;
  return !(value == null);
};

final binaryEqualityAnd = () {
  dynamic value;
  return (value == null) && true;
};

final binaryEqualityOr = () {
  dynamic value;
  return (value == null) || false;
};

final binaryEqualityStoredLocally = () {
  dynamic value;
  final compared = value == null;
  return compared;
};

final binaryEqualityInBranch = () {
  dynamic value;
  return value == null ? value == 1 : false;
};

final binaryEqualityInSwitchBranch = () {
  dynamic value;
  return switch (true) {
    true => value == null,
    false => false,
  };
};

final binaryEqualityCoalesced = () {
  dynamic value;
  return (value == null) ?? false;
};

final binaryEqualityInvokedClosure = () {
  dynamic value;
  compare() => value == null;
  return compare();
};

final binaryInequalityInsideComparison = () {
  dynamic value;
  return (value != null) == true;
};
