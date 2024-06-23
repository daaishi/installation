import 'dart:io';

import 'package:osc/osc.dart';

class OSCService {
  static Future<void> sendMessage(String command) async {
    String ipAddress = command.split(' ')[0].split(':')[0];
    int port = int.parse(command.split(' ')[0].split(':')[1]);
    String oscAddress = command.split(' ')[1];
    List<String> commandParts = command.split(' ');
    int argsIndex = commandParts.indexOf('-args');
    List<String> rawArguments =
        argsIndex != -1 ? commandParts.sublist(argsIndex + 1) : [];

    List<Object> oscArguments = rawArguments.map((String arg) {
      if (arg.startsWith('"') && arg.endsWith('"')) {
        return arg.substring(1, arg.length - 1); // ダブルクオーテーションを除去して文字列として扱う
      } else if (RegExp(r'[a-zA-Z]').hasMatch(arg)) {
        return arg; // アルファベットが含まれている場合は文字列として扱う
      } else if (double.tryParse(arg) != null && arg.contains('.')) {
        return double.parse(arg); // 小数点が含まれていればfloat
      } else if (int.tryParse(arg) != null) {
        return int.parse(arg); // 小数点がなければint
      } else {
        return arg.toString(); // その他は文字列
      }
    }).toList();

    final message = OSCMessage(
      oscAddress,
      arguments: oscArguments,
    );

    RawDatagramSocket.bind(InternetAddress.anyIPv4, 0)
        .then((RawDatagramSocket socket) {
      socket.send(message.toBytes(), InternetAddress(ipAddress), port);
      socket.close();
    });
  }
}
