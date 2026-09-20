import '../repository/todo_repository.dart';
import '../view/todo_widget.dart';

class TodoPresenter {
  TodoPresenter(this.repository, this.page);

  final TodoRepository repository;
  final TodoWidget page;
}
