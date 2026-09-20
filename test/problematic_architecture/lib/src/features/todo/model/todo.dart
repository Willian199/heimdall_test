import '../view_model/todo_presenter.dart';

class Todo {
  Todo({required this.id, required this.owner});

  String id;
  final TodoPresenter owner;
}
