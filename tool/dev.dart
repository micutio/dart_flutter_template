import 'dart:async';
import 'dart:io';

/// Cross-platform developer task runner for the todo monorepo.
Future<void> main(List<String> args) async {
  if (args.isEmpty ||
      args.first == 'help' ||
      args.first == '--help' ||
      args.first == '-h') {
    _printHelp();
    exit(0);
  }

  final command = args.first;
  final rest = args.sublist(1);

  final code = await _runCommand(command, rest);
  exit(code);
}

void _printHelp() {
  stdout
    ..writeln('Todo Monorepo Task Runner')
    ..writeln()
    ..writeln('Usage: dart run tool/dev.dart <command> [options]')
    ..writeln('   or: dart tool/dev.dart <command> [options]')
    ..writeln()
    ..writeln('Commands:')
    ..writeln(
      '  format, fmt [--check]     Format code (or check formatting with --check)',
    )
    ..writeln(
      '  analyze, lint             Run static analysis across all workspaces',
    )
    ..writeln(
      '  fix [--check]             Apply automated fixes (or dry-run with --check)',
    )
    ..writeln('  test                      Run all tests (core, cli, and app)')
    ..writeln('  test:core, test-core      Run core package unit tests')
    ..writeln('  test:cli, test-cli        Run CLI package unit tests')
    ..writeln('  test:app, test-app        Run Flutter app widget tests')
    ..writeln(
      '  build:cli, build-cli      Build the native CLI executable bundle',
    )
    ..writeln(
      '  smoke:cli, smoke-cli      Run smoke test on the compiled CLI binary',
    )
    ..writeln(
      '  build:app, build-app      Build the debug Android APK for packages/app',
    )
    ..writeln(
      '  verify, check, ci         Run full CI validation suite locally',
    )
    ..writeln('  help                      Show this help message');
}

Future<int> _runCommand(String command, List<String> rest) async {
  switch (command) {
    case 'format':
    case 'fmt':
      return _format(isCheck: rest.contains('--check'));

    case 'analyze':
    case 'lint':
      return _analyze();

    case 'fix':
      return _fix(isCheck: rest.contains('--check'));

    case 'test':
      return _testAll();

    case 'test:core':
    case 'test-core':
      return _testCore();

    case 'test:cli':
    case 'test-cli':
      return _testCli();

    case 'test:app':
    case 'test-app':
      return _testApp();

    case 'build:cli':
    case 'build-cli':
      return _buildCli();

    case 'smoke:cli':
    case 'smoke-cli':
      return _smokeCli();

    case 'build:app':
    case 'build-app':
    case 'build-android':
      return _buildApp();

    case 'verify':
    case 'check':
    case 'ci':
      return _verify();

    default:
      stderr.writeln("Unknown command: '$command'");
      stdout.writeln();
      _printHelp();
      return 1;
  }
}

Future<int> _format({required bool isCheck}) async {
  final args = isCheck
      ? ['format', '--output=none', '--set-exit-if-changed', '.']
      : ['format', '.'];
  return _exec('dart', args);
}

Future<int> _analyze() async {
  return _exec('dart', ['analyze', '--fatal-infos']);
}

Future<int> _fix({required bool isCheck}) async {
  if (isCheck) {
    stdout.writeln('\n> Running: dart fix --dry-run');
    final result = await Process.run('dart', [
      'fix',
      '--dry-run',
    ], runInShell: true);
    stdout.write(result.stdout);
    stderr.write(result.stderr);
    if (result.exitCode != 0) return result.exitCode;

    final output = result.stdout.toString();
    if (!output.contains('Nothing to fix!')) {
      stderr.writeln(
        "Automated Dart fixes are available. Run 'dart run tool/dev.dart fix'.",
      );
      return 1;
    }
    return 0;
  } else {
    return _exec('dart', ['fix', '--apply']);
  }
}

Future<int> _testCore() async {
  return _exec('dart', ['test', 'packages/core']);
}

Future<int> _testCli() async {
  return _exec('dart', ['test', 'packages/cli']);
}

Future<int> _testApp() async {
  return _exec('flutter', ['test', 'packages/app']);
}

Future<int> _testAll() async {
  final coreCode = await _testCore();
  if (coreCode != 0) return coreCode;

  final cliCode = await _testCli();
  if (cliCode != 0) return cliCode;

  return _testApp();
}

Future<int> _buildCli() async {
  return _exec('dart', ['build', 'cli'], workingDirectory: 'packages/cli');
}

Future<int> _smokeCli() async {
  return _exec('dart', [
    'run',
    'tool/smoke_cli.dart',
  ], workingDirectory: 'packages/cli');
}

Future<int> _buildApp() async {
  return _exec('flutter', [
    'build',
    'apk',
    '--debug',
  ], workingDirectory: 'packages/app');
}

Future<int> _verify() async {
  stdout
    ..writeln('=== Running Monorepo Verification Suite ===')
    ..writeln('\n[1/6] Format check...');
  final fmt = await _format(isCheck: true);
  if (fmt != 0) {
    stderr.writeln('Format check failed!');
    return fmt;
  }

  stdout.writeln('\n[2/6] Static analysis...');
  final lnt = await _analyze();
  if (lnt != 0) {
    stderr.writeln('Static analysis failed!');
    return lnt;
  }

  stdout.writeln('\n[3/6] Fix check...');
  final fx = await _fix(isCheck: true);
  if (fx != 0) {
    stderr.writeln('Fix check failed!');
    return fx;
  }

  stdout.writeln('\n[4/6] Running tests (core, cli, app)...');
  final tst = await _testAll();
  if (tst != 0) {
    stderr.writeln('Tests failed!');
    return tst;
  }

  stdout.writeln('\n[5/6] Building native CLI bundle...');
  final bld = await _buildCli();
  if (bld != 0) {
    stderr.writeln('CLI build failed!');
    return bld;
  }

  stdout.writeln('\n[6/6] Smoke testing CLI bundle...');
  final smk = await _smokeCli();
  if (smk != 0) {
    stderr.writeln('CLI smoke test failed!');
    return smk;
  }

  stdout.writeln('\nAll verification checks passed successfully!');
  return 0;
}

Future<int> _exec(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
}) async {
  final displayDir = workingDirectory != null ? ' (in $workingDirectory)' : '';
  stdout.writeln('\n> Running: $executable ${arguments.join(' ')}$displayDir');
  final process = await Process.start(
    executable,
    arguments,
    workingDirectory: workingDirectory,
    mode: ProcessStartMode.inheritStdio,
    runInShell: true,
  );
  return process.exitCode;
}
