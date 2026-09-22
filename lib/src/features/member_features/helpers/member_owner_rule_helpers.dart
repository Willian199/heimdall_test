import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Applies [classPredicate] to a member's owner and reports member-level failures.
HeimdallCondition<ClassMember> memberShouldBeDeclaredInClassesThat(
  HeimdallPredicate<CompilationUnitMember> classPredicate,
) {
  return memberCondition(
    'be declared in classes that ${classPredicate.description}',
    (item, project) => classPredicate.test(item.owner, project),
  );
}
