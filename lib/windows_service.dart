import 'dart:io';
import 'package:installation/app_data.dart';
import 'package:path/path.dart' as pathLib;
import 'package:process_run/shell.dart';

class WindowsService {
  static Future<void> restart() async {
    await Process.run('shutdown', ['/r', '/t', '0']);
  }

  static Future<void> shutdown() async {
    await Process.run('shutdown', ['/s', '/t', '0']);
  }

  static Future<void> appControl(String command) async {
    final pathRegExp = RegExp(r'-path\s+([^\-]+)');
    final argRegExp = RegExp(r'-arg\s+([^\-]+)');

    String? path = _extractValue(pathRegExp, command);
    String? arg = _extractValue(argRegExp, command);

    var scriptDirectory = pathLib.dirname(Platform.resolvedExecutable);
    logger.i('scriptDirectory: $scriptDirectory');
    // "scripts"ディレクトリ内の"close_process.ps1"までの絶対パスを組み立てる
    var scriptPath =
        pathLib.join(scriptDirectory, 'scripts', 'close_process.ps1');

    String? processName = pathLib.basenameWithoutExtension(path ?? "");
    String? exeName = pathLib.basename(path ?? "");

    if (arg == 'close') {
      var commandPowerShell =
          "powershell.exe -ExecutionPolicy RemoteSigned -File \"$scriptPath\" -processName $processName";

      try {
        var shell = Shell();
        var result = await shell.run(commandPowerShell);
        logger.d('result: $result');
      } catch (e) {
        logger.e(e);
      }
    } else if (arg == 'kill') {
      var shell = Shell();
      try {
        await shell.run('''
          taskkill /im $exeName /F
          ''');
      } catch (e) {
        logger.e(e);
      }
    } else if (arg == 'start') {
      var shell = Shell();
      try {
        await shell.run(
          '''
            cmd /c start "" "$path"
          '''
        );
      }
      catch (e) {
        logger.e('Error: $e');
      }
    }
  }

  static String? _extractValue(RegExp regExp, String input) {
    final match = regExp.firstMatch(input);
    return match?.group(1)?.trim();
  }
}
