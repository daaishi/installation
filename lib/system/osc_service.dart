import 'dart:io';

import 'package:osc/osc.dart';

class OSCService {
  static Future<void> sendMessage(String command) async {

    String ipAddress = command.split(' ')[0].split(':')[0];
    int port = int.parse(command.split(' ')[0].split(':')[1]);
    String oscAddress = command.split(' ')[1];
    List<String> commandParts = command.split(' ');
    int argsIndex = commandParts.indexOf('-args');
    List<String> oscArguments = argsIndex != -1 ? commandParts.sublist(argsIndex + 1) : [];

    final message = OSCMessage(
      oscAddress,
      arguments: oscArguments,
    );

    RawDatagramSocket.bind(InternetAddress.anyIPv4, 0).then((RawDatagramSocket socket) {
      socket.send(
        message.toBytes(), 
        InternetAddress(ipAddress),
        port
      );
      socket.close();
    });


  }
}