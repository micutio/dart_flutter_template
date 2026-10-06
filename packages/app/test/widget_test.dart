import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/main.dart';

void main() {
  testWidgets('TodoApp displays title and initial items from todo_core', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TodoApp());

    expect(find.text('Eisenhower Todo'), findsOneWidget);
    expect(find.text('Review PR & verify CI'), findsOneWidget);
    expect(find.text('Design DDD architecture'), findsOneWidget);

    // Toggle completion checkbox
    final firstCheckbox = find.byType(Checkbox).first;
    await tester.tap(firstCheckbox);
    await tester.pump();

    // Tap FloatingActionButton to add a new task
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    expect(find.text('New Quick Task'), findsOneWidget);
  });
}
