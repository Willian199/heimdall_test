import '../model/todo.dart';
import '../repository/todo_repository.dart';
import '../view_model/todo_presenter.dart';

class TodoWidget {
  TodoWidget(this.repository, this.viewModel);

  final TodoRepository repository;
  final TodoPresenter viewModel;

  Todo? selectedTodo;

  String renderTitle() => selectedTodo?.id ?? repository.loadTodo().id;
}
