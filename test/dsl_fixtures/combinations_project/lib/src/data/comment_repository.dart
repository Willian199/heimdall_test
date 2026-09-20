import '../domain/user.dart';

class CommentRepository {
  final String description = 'User appears only in a string';

  // DomainService appears only in a comment.
  String describe() => description;
}
