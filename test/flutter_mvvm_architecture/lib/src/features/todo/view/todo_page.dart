import '../view_model/todo_view_model.dart';

class TodoPage {
  const TodoPage(this.viewModel);

  final TodoViewModel viewModel;

  String renderTitle() => viewModel.todos.first.title;
}
