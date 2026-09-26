import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  test('different import option lists do not share a cache entry', () {
    HeimdallFileImporter.clearCache();
    const root = 'test/importer_fixtures/cache_key_collision';

    final firstOptionsProject = HeimdallFileImporter(
      importOptions: [
        _FixtureOption('first|second', (path) => path.endsWith('first.dart')),
      ],
    ).importPath(root);
    final secondOptionsProject = HeimdallFileImporter(
      importOptions: [
        _FixtureOption('first', (_) => true),
        _FixtureOption('second', (path) => path.endsWith('second.dart')),
      ],
    ).importPath(root);

    expect(
      firstOptionsProject.files.map((file) => file.relativePath),
      ['lib/first.dart'],
    );
    expect(
      secondOptionsProject.files.map((file) => file.relativePath),
      ['lib/second.dart'],
    );
  });
}

final class _FixtureOption implements ImportOption {
  const _FixtureOption(this.cacheKey, this.predicate);

  @override
  final String cacheKey;

  final bool Function(String absolutePath) predicate;

  @override
  bool includes(String absolutePath) => predicate(absolutePath);
}
