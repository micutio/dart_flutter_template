import 'package:test/test.dart';
import 'package:todo_cli/todo_cli.dart';

void main() {
  group('Todo CLI', () {
    test('buildParser creates parser with flags', () {
      final parser = buildParser();
      expect(parser.options.containsKey('help'), isTrue);
      expect(parser.options.containsKey('version'), isTrue);
    });

    test('runCli handles --help flag', () {
      final code = runCli(['--help']);
      expect(code, equals(0));
    });

    test('runCli handles --version flag', () {
      final code = runCli(['--version']);
      expect(code, equals(0));
    });

    test('runCli handles default execution', () {
      final code = runCli([]);
      expect(code, equals(0));
    });

    test('runCli handles invalid options', () {
      final code = runCli(['--unknown-option-xyz']);
      expect(code, equals(64));
    });

    test('runCli supports custom StringSink for out and err', () {
      final out = StringBuffer();
      final code = runCli(['--version'], out: out);
      expect(code, equals(0));
      expect(out.toString(), contains('todo version'));

      final err = StringBuffer();
      final errCode = runCli(['--invalid-flag'], err: err);
      expect(errCode, equals(64));
      expect(err.toString(), contains('Could not find an option'));
    });
  });
}
