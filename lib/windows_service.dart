import 'dart:io';

class WindowsService {
  static Future<void> restart() async {
    await Process.run('shutdown', ['/r', '/t', '0']);
  }
}