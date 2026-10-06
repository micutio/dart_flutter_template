enum EisenhowerQuadrant {
  urgentAndImportant(
    label: 'Do First',
    description: 'Urgent & Important tasks to tackle immediately.',
  ),
  notUrgentAndImportant(
    label: 'Schedule',
    description: 'Important goals with no immediate deadline.',
  ),
  urgentAndNotImportant(
    label: 'Delegate',
    description: 'Urgent interruptions that can be delegated or batched.',
  ),
  notUrgentAndNotImportant(
    label: 'Eliminate',
    description: 'Trivial tasks that can be deferred or removed.',
  );

  const EisenhowerQuadrant({required this.label, required this.description});

  final String label;
  final String description;
}
