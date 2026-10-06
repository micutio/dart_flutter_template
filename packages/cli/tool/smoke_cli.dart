import 'dart:io';

import 'package:path/path.dart' as p;

/// Runs smoke tests against the compiled CLI binary.
void main() {
  exitCode = _smoke();
}

int _smoke() {
  final binary = _findBinary();
  stdout.writeln('Smoke testing CLI at $binary');

  // 1. Test --help
  final help = Process.runSync(binary, ['--help']);
  stdout.write(help.stdout);
  stderr.write(help.stderr);
  if (help.exitCode != 0) {
    stderr.writeln('--help failed with exit code ${help.exitCode}');
    return help.exitCode;
  }
  if (!help.stdout.toString().contains('Todo CLI')) {
    stderr.writeln('Expected --help output to contain "Todo CLI"');
    return 1;
  }

  // 2. Test --version
  final version = Process.runSync(binary, ['--version']);
  stdout.write(version.stdout);
  stderr.write(version.stderr);
  if (version.exitCode != 0) {
    stderr.writeln('--version failed with exit code ${version.exitCode}');
    return version.exitCode;
  }
  if (!version.stdout.toString().contains('todo version')) {
    stderr.writeln('Expected --version output to contain "todo version"');
    return 1;
  }

  // 3. Test default run
  final run = Process.runSync(binary, []);
  stdout.write(run.stdout);
  stderr.write(run.stderr);
  if (run.exitCode != 0) {
    stderr.writeln('Default run failed with exit code ${run.exitCode}');
    return run.exitCode;
  }
  if (!run.stdout.toString().contains('=== Todo CLI')) {
    stderr.writeln('Expected output to contain "=== Todo CLI"');
    return 1;
  }

  stdout.writeln('CLI smoke test passed successfully.');
  return 0;
}

String _findBinary() {
  final candidates = [
    Directory('build/cli'),
    Directory('packages/cli/build/cli'),
  ];

  for (final dir in candidates) {
    if (dir.existsSync()) {
      final matches = dir.listSync(recursive: true).whereType<File>().where((
        file,
      ) {
        final name = p.basename(file.path);
        return name == 'todo' || name == 'todo.exe';
      }).toList();

      if (matches.isNotEmpty) {
        return matches.first.absolute.path;
      }
    }
  }

  stderr.writeln(
    'No todo binary found under build/cli or packages/cli/build/cli. Run dart build cli first.',
  );
  exit(1);
}
