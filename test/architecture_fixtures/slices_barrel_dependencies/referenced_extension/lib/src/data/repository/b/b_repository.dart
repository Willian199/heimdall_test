abstract interface class BRepository {}

int repositoryValue() => 1;

extension RepositoryExtension on String {
  int get repositoryExtensionValue => 1;
}
