import '../model/todo.dart';
import '../repository/todo_repository.dart';

class TodoViewModel {
  TodoViewModel(this.repository);

  final TodoRepository repository;

  List<Todo> get todos => repository.loadTodos();
}
