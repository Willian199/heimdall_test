import '../model/todo.dart';

class TodoRepository {
  List<Todo> loadTodos() {
    return const [
      Todo(id: '1', title: 'Write architecture tests'),
    ];
  }
}
