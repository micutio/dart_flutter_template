import 'eisenhower_quadrant.dart';

class TodoItem {
  TodoItem({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.isUrgent = false,
    this.isImportant = false,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final bool isUrgent;
  final bool isImportant;
  final bool isCompleted;
  final DateTime createdAt;

  EisenhowerQuadrant get quadrant {
    if (isUrgent && isImportant) {
      return EisenhowerQuadrant.urgentAndImportant;
    } else if (!isUrgent && isImportant) {
      return EisenhowerQuadrant.notUrgentAndImportant;
    } else if (isUrgent && !isImportant) {
      return EisenhowerQuadrant.urgentAndNotImportant;
    } else {
      return EisenhowerQuadrant.notUrgentAndNotImportant;
    }
  }

  TodoItem copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isUrgent,
    bool? isImportant,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isUrgent: isUrgent ?? this.isUrgent,
      isImportant: isImportant ?? this.isImportant,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          dueDate == other.dueDate &&
          isUrgent == other.isUrgent &&
          isImportant == other.isImportant &&
          isCompleted == other.isCompleted &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    dueDate,
    isUrgent,
    isImportant,
    isCompleted,
    createdAt,
  );
}
