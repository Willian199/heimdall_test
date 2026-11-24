import 'additional/cases.dart' as additional;
import 'cases.dart' as fixtures;
import 'deep/cases.dart' as deep;
import 'homonyms/cases.dart' as homonyms;

void main() {
  final mismatches = <String>[];
  final cases = [...fixtures.cases, ...additional.cases, ...deep.cases, ...homonyms.cases];
  for (final edge in cases) {
    final actual = edge.actual();
    if (actual != edge.expected) {
      mismatches.add(edge.name + ': expected ' + edge.expected.toString() + ', got ' + actual.toString());
    }
  }
  if (mismatches.isNotEmpty) {
    throw StateError(mismatches.join('\n'));
  }
  print('Compiled and checked ' + cases.length.toString() + ' distinct fixtures.');
}
