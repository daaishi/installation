import 'dart:convert';
import 'dart:io';
import 'package:installation/app_data.dart';
import 'package:path_provider/path_provider.dart';

class FileManager {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/installation.json');
  }

  Future<File> writeData(String json) async {
    final file = await _localFile;
    return file.writeAsString(json);
  }

  Future<String> readData() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      return contents;
    } catch (e) {
      return '{"startupData": [], "eventData": [], "systemData": {}}';
    }
  }

  Future<void> saveData(AppData appData) async {
    String jsonData = json.encode(appData.toJson());
    await writeData(jsonData);
  }

  Future<void> openLocalPathInExplorer() async {
    final path = await _localPath;
    // Windowsのエクスプローラーを使用
    await Process.run('explorer', [path]);
  }
}