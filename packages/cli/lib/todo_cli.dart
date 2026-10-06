import 'dart:io';

import 'package:args/args.dart';
import 'package:todo_core/todo_core.dart';

const String cliVersion = '0.1.0';

ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print usage information.',
    )
    ..addFlag(
      'version',
      abbr: 'v',
      negatable: false,
      help: 'Print application version.',
    );
}

int runCli(List<String> args, {Stdout? out, Stdout? err}) {
  final stdoutSink = out ?? stdout;
  final parser = buildParser();

  try {
    final results = parser.parse(args);

    if (results.flag('help')) {
      stdoutSink.writeln(
        'Todo CLI - Task management driven by Eisenhower priorities',
      );
      stdoutSink.writeln();
      stdoutSink.writeln('Usage: todo [options]');
      stdoutSink.writeln();
      stdoutSink.writeln(parser.usage);
      return 0;
    }

    if (results.flag('version')) {
      stdoutSink.writeln('todo version $cliVersion');
      return 0;
    }

    final list = TodoList(
      id: 'default',
      name: 'Default Stream',
      items: [
        TodoItem(
          id: '1',
          title: 'Review PR & run CI checks',
          isUrgent: true,
          isImportant: true,
        ),
        TodoItem(
          id: '2',
          title: 'Plan architecture using DDD',
          isUrgent: false,
          isImportant: true,
        ),
        TodoItem(
          id: '3',
          title: 'Organize workspace cleanups',
          isUrgent: false,
          isImportant: false,
        ),
      ],
    );

    stdoutSink.writeln('=== Todo CLI (${list.name}) ===');
    for (final item in list.prioritizedItems()) {
      final status = item.isCompleted ? '[x]' : '[ ]';
      final quadrant = '[${item.quadrant.label}]';
      stdoutSink.writeln('$status $quadrant ${item.title}');
    }

    return 0;
  } on FormatException catch (e) {
    (err ?? stderr).writeln(e.message);
    (err ?? stderr).writeln();
    (err ?? stderr).writeln(parser.usage);
    return 64;
  }
}
