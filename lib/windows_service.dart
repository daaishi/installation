import 'dart:io';
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

    var scriptDirectory = pathLib.dirname(Platform.script.toFilePath());
    // "scripts"ディレクトリ内の"close_process.ps1"までの絶対パスを組み立てる
    var scriptPath = pathLib.join(scriptDirectory, 'scripts', 'close_process.ps1');


    String? processName = pathLib.basenameWithoutExtension(path ?? "");
    String? exeName = pathLib.basename(path ?? "");

    if (arg == 'close') {
      // PowerShellスクリプトのパス
      // PowerShellコマンド
      var commandPowerShell = "powershell.exe -ExecutionPolicy RemoteSigned -File $scriptPath -processName $processName";
      print(commandPowerShell);

      try {
        var result = await Process.run('cmd', ['/c', commandPowerShell], runInShell: true);
        print(result.stdout);
      } catch (e) {
        print(e);
      }
    }
    else if (arg == 'kill') {
      var shell = Shell();
      try {
        await shell.run(
          '''
          taskkill /im $exeName
          '''
        );
      }
      catch (e) {
        print(e);
      }
    }

  }

  static String? _extractValue(RegExp regExp, String input) {
  final match = regExp.firstMatch(input);
  return match?.group(1)?.trim();
}
}