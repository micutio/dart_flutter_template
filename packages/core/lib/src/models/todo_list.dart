import 'todo_item.dart';

class TodoList {
  TodoList({required this.id, required this.name, List<TodoItem>? items})
    : _items = List<TodoItem>.unmodifiable(items ?? const []);

  final String id;
  final String name;
  final List<TodoItem> _items;

  List<TodoItem> get items => _items;

  int get length => _items.length;
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  TodoList addItem(TodoItem item) {
    return TodoList(id: id, name: name, items: [..._items, item]);
  }

  TodoList removeItem(String itemId) {
    return TodoList(
      id: id,
      name: name,
      items: _items.where((item) => item.id != itemId).toList(),
    );
  }

  TodoList toggleItem(String itemId) {
    return TodoList(
      id: id,
      name: name,
      items: _items.map((item) {
        if (item.id == itemId) {
          return item.copyWith(isCompleted: !item.isCompleted);
        }
        return item;
      }).toList(),
    );
  }

  /// Returns items sorted by priority:
  /// 1. Uncompleted items before completed items.
  /// 2. Eisenhower quadrant (Q1, Q2, Q3, Q4).
  /// 3. Earliest due date first (if due dates exist).
  List<TodoItem> prioritizedItems() {
    final sorted = List<TodoItem>.from(_items);
    sorted.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      final quadComp = a.quadrant.index.compareTo(b.quadrant.index);
      if (quadComp != 0) return quadComp;

      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      } else if (a.dueDate != null) {
        return -1;
      } else if (b.dueDate != null) {
        return 1;
      }
      return a.createdAt.compareTo(b.createdAt);
    });
    return List<TodoItem>.unmodifiable(sorted);
  }
}
