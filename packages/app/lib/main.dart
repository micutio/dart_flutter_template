import 'package:flutter/material.dart';
import 'package:todo_core/todo_core.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TodoHomePage(title: 'Eisenhower Todo'),
    );
  }
}

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key, required this.title});

  final String title;

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  late TodoList _todoList;

  @override
  void initState() {
    super.initState();
    _todoList = TodoList(
      id: 'stream-1',
      name: 'Main Stream',
      items: [
        TodoItem(
          id: '1',
          title: 'Review PR & verify CI',
          isUrgent: true,
          isImportant: true,
        ),
        TodoItem(
          id: '2',
          title: 'Design DDD architecture',
          isUrgent: false,
          isImportant: true,
        ),
        TodoItem(
          id: '3',
          title: 'Reply to routine notifications',
          isUrgent: true,
          isImportant: false,
        ),
        TodoItem(
          id: '4',
          title: 'Archive old notes',
          isUrgent: false,
          isImportant: false,
        ),
      ],
    );
  }

  void _toggleItem(String id) {
    setState(() {
      _todoList = _todoList.toggleItem(id);
    });
  }

  void _addItem() {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      _todoList = _todoList.addItem(
        TodoItem(
          id: newId,
          title: 'New Quick Task',
          isUrgent: true,
          isImportant: true,
        ),
      );
    });
  }

  Color _quadrantColor(EisenhowerQuadrant quadrant) {
    switch (quadrant) {
      case EisenhowerQuadrant.urgentAndImportant:
        return Colors.red.shade700;
      case EisenhowerQuadrant.notUrgentAndImportant:
        return Colors.blue.shade700;
      case EisenhowerQuadrant.urgentAndNotImportant:
        return Colors.orange.shade800;
      case EisenhowerQuadrant.notUrgentAndNotImportant:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final prioritized = _todoList.prioritizedItems();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: prioritized.length,
        itemBuilder: (context, index) {
          final item = prioritized[index];
          final color = _quadrantColor(item.quadrant);

          return ListTile(
            leading: Checkbox(
              value: item.isCompleted,
              onChanged: (_) => _toggleItem(item.id),
            ),
            title: Text(
              item.title,
              style: TextStyle(
                decoration: item.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
            subtitle: Text(item.quadrant.description),
            trailing: Chip(
              label: Text(
                item.quadrant.label,
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
              backgroundColor: color,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}
