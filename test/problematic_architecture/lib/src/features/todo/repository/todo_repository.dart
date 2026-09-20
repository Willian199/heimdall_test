import '../model/todo.dart';
import '../view/todo_widget.dart';

class TodoRepository {
  TodoRepository(this.page);

  final TodoWidget page;

  Todo loadTodo() {
    return Todo(id: page.renderTitle(), owner: page.viewModel);
  }
}
