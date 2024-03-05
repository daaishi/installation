import 'dart:io';
import 'dart:async';

class PJLinkService {
  final String ipAddress;
  final int port;
  final String command;

  PJLinkService({required String commandString})
    : ipAddress = commandString.split(' ')[0].split(':')[0],
      port = int.parse(commandString.split(' ')[0].split(':')[1]),
      command = commandString.split(' ')[1];

  Future<void> executeCommand() async {
    switch (command) {
      case 'on':
        await turnOnProjector();
        break;
      case 'off':
        await turnOffProjector();
        break;
      default:
        print('Unknown command: $command');
    }
  }

  Future<void> turnOffProjector() async {
    String command = '%1POWR 0\r';

    var socket = await Socket.connect(ipAddress, port);
    print('Turn off projector : ${socket.remoteAddress.address}:${socket.remotePort}');
    socket.write(command);
    await socket.flush();
    socket.listen((event) {
      print(event);
    }, onDone: () {
      print('Disconnected from : ${socket.remoteAddress.address}:${socket.remotePort}');
      socket.destroy();
    });
  }

  // Projector power on
  Future<void> turnOnProjector() async {
    String command = '%1POWR 1\r';

    var socket = await Socket.connect(ipAddress, port);
    print('Turn on projector: ${socket.remoteAddress.address}:${socket.remotePort}');
    socket.write(command);
    await socket.flush();
    socket.listen((event) {
      print(event);
    }, onDone: () {
      print('Disconnected from : ${socket.remoteAddress.address}:${socket.remotePort}');
      socket.destroy();
    });
  }
}

