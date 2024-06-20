import 'package:installation/event_data.dart';
import 'package:installation/startup_data.dart';
import 'package:installation/osc_service.dart';
import 'package:installation/pj_link_service.dart';
import 'package:installation/windows_service.dart';
import 'package:process_run/shell.dart';

class ExecuteService {
  static Future<void> executeEventCommand(EventData data) async {
    if (data.type == 'pjlink') {
      var pjLinkService = PJLinkService(commandString: data.command);
      pjLinkService.executeCommand();
    } else if (data.type == 'system') {
      logger.i('System command: ${data.command}');
      if (data.command == 'restart') {
        WindowsService.restart();
      }
      else if (data.command == 'shutdown') {
        WindowsService.shutdown();
      }
    } else if (data.type == 'app') {
      WindowsService.appControl(data.command);
    } else if (data.type == 'osc') {
      try {
        OSCService.sendMessage(data.command);
      } catch (e) {
        logger.e('Error: $e');
      }
    }
  }

  static Future<void> executeStartupCommand(StartupData data) async {
    if (data.type == 'pjlink') {
      var pjLinkService = PJLinkService(commandString: data.command);
      pjLinkService.executeCommand();
    } else if (data.type == 'app') {
      try {
        var shell = Shell();
        await shell.run(
          '''
            cmd /c start "" "${data.command}"
          '''
        );
      }
      catch (e) {
        logger.e('Error: $e');
      }
    }
  }
  

  static Future<void> executeStartupCommands(List<StartupData> startupDataList) async {
    for (var data in startupDataList) {
      Future.delayed(Duration(seconds: data.duration), () {
        executeStartupCommand(data);
      });
    }
  }

  static Future<void> executeEventCommands(List<EventData> eventDataList) async {
    for (var data in eventDataList) {
      await executeEventCommand(data);
    }
  }
}