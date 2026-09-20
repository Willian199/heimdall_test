import 'dart:async';

import 'prefixed_generic.dart' as generic;

dynamic publicTopLevelDynamic;
var publicTopLevelImplicit;
final publicTopLevelInferred = 1;

typedef RawFutureAlias = Future;
typedef DynamicFutureAlias = Future<dynamic>;
typedef DynamicAlias = dynamic;
typedef DynamicListAlias = List<dynamic>;
typedef DynamicSetAlias = Set<dynamic>;
typedef DynamicIterableAlias = Iterable<dynamic>;
typedef DynamicMapAlias = Map<String, dynamic>;
typedef DynamicCallback = dynamic Function(dynamic value);
typedef dynamic LegacyDynamicCallback(dynamic value);

void wildcardParameter(_) {}
void callbackParameter(void Function(dynamic value) callback) {}

class DynamicSignature {
  dynamic publicFieldDynamic;
  Future publicRawFuture;
  Future<dynamic> publicDynamicFuture;
  Cubit publicRawCubit;
  Cubit<dynamic> publicDynamicCubit;
  generic.PrefixedGeneric publicRawPrefixedGeneric;
  List<dynamic> publicListDynamic;
  Set<dynamic> publicSetDynamic;
  Iterable<dynamic> publicIterableDynamic;
  Map<String, dynamic> publicMapDynamic;
  var publicFieldImplicit;
  final publicFieldInferred = 'value';

  dynamic explicitReturn(dynamic explicitParameter) => explicitParameter;

  Future rawFutureReturn(Future rawFutureParameter) async => rawFutureParameter;
  Future<dynamic> dynamicFutureReturn(Future<dynamic> dynamicFutureParameter) async => dynamicFutureParameter;
  Cubit rawCubitReturn(Cubit rawCubitParameter) => rawCubitParameter;
  Cubit<dynamic> dynamicCubitReturn(Cubit<dynamic> dynamicCubitParameter) => dynamicCubitParameter;
  List<dynamic> nestedReturn() => const [];
  Set<dynamic> nestedSetReturn() => const {};
  Iterable<dynamic> nestedIterableReturn() => const [];
  Map<String, dynamic> nestedMapReturn() => const {};

  implicitReturn(implicitParameter) => implicitParameter;
}

class FieldFormalSignature {
  const FieldFormalSignature({
    this.codigo,
    this.parametro,
  });

  final int? codigo;
  final num? parametro;
}

class SuperFormalBaseSignature {
  const SuperFormalBaseSignature({
    this.codigo,
  });

  final int? codigo;
}

class SuperFormalSignature extends SuperFormalBaseSignature {
  const SuperFormalSignature({
    super.codigo,
  });
}

class Cubit<T> {
  const Cubit();
}
