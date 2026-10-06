import 'package:test/test.dart';
import 'package:todo_core/todo_core.dart';

void main() {
  group('EisenhowerQuadrant', () {
    test('correctly infers quadrant from urgency and importance', () {
      final q1 = TodoItem(
        id: '1',
        title: 'Task 1',
        isUrgent: true,
        isImportant: true,
      );
      expect(q1.quadrant, equals(EisenhowerQuadrant.urgentAndImportant));

      final q2 = TodoItem(
        id: '2',
        title: 'Task 2',
        isUrgent: false,
        isImportant: true,
      );
      expect(q2.quadrant, equals(EisenhowerQuadrant.notUrgentAndImportant));

      final q3 = TodoItem(
        id: '3',
        title: 'Task 3',
        isUrgent: true,
        isImportant: false,
      );
      expect(q3.quadrant, equals(EisenhowerQuadrant.urgentAndNotImportant));

      final q4 = TodoItem(
        id: '4',
        title: 'Task 4',
        isUrgent: false,
        isImportant: false,
      );
      expect(q4.quadrant, equals(EisenhowerQuadrant.notUrgentAndNotImportant));
    });
  });

  group('TodoList', () {
    test('adds and removes items', () {
      final list = TodoList(id: 'l1', name: 'Work');
      expect(list.isEmpty, isTrue);

      final item = TodoItem(id: 't1', title: 'Finish docs');
      final updated = list.addItem(item);
      expect(updated.length, equals(1));
      expect(updated.items.first.title, equals('Finish docs'));

      final removed = updated.removeItem('t1');
      expect(removed.isEmpty, isTrue);
    });

    test('toggles item completion', () {
      final item = TodoItem(id: 't1', title: 'Task 1');
      final list = TodoList(id: 'l1', name: 'Work', items: [item]);

      final toggled = list.toggleItem('t1');
      expect(toggled.items.first.isCompleted, isTrue);

      final untoggled = toggled.toggleItem('t1');
      expect(untoggled.items.first.isCompleted, isFalse);
    });

    test('prioritizes items by completion status, quadrant, and due date', () {
      final now = DateTime.now();
      final doneUrgent = TodoItem(
        id: '1',
        title: 'Done urgent',
        isUrgent: true,
        isImportant: true,
        isCompleted: true,
      );
      final q2Task = TodoItem(
        id: '2',
        title: 'Q2 task',
        isUrgent: false,
        isImportant: true,
      );
      final q1Sooner = TodoItem(
        id: '3',
        title: 'Q1 sooner',
        isUrgent: true,
        isImportant: true,
        dueDate: now.add(const Duration(days: 1)),
      );
      final q1Later = TodoItem(
        id: '4',
        title: 'Q1 later',
        isUrgent: true,
        isImportant: true,
        dueDate: now.add(const Duration(days: 3)),
      );

      final list = TodoList(
        id: 'l1',
        name: 'Work',
        items: [doneUrgent, q2Task, q1Later, q1Sooner],
      );

      final prioritized = list.prioritizedItems();
      expect(
        prioritized.map((i) => i.id).toList(),
        equals(['3', '4', '2', '1']),
      );
    });
  });
}
