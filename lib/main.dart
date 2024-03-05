import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:installation/event_view.dart';
import 'package:installation/file_manager.dart';
import 'package:installation/pj_link_service.dart';
import 'package:installation/startup_view.dart';
import 'package:installation/app_data.dart';
import 'package:process_run/shell.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_view.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  FileManager fileManager = FileManager();

  AppData appData = await loadAppData(fileManager);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isStartupEnabled = prefs.getBool('isStartupEnabled') ?? false;
  if (isStartupEnabled) {
    executeStartupCommands(appData);
  }

  runApp(
    ChangeNotifierProvider<AppData>(
      create: (context) => appData,
      child: MainApp(),
    ),
  );
}

Future<AppData> loadAppData(FileManager fileManager) async {
  String dataJson = await fileManager.readData();
  Map<String, dynamic> jsonData = json.decode(dataJson);
  return AppData.fromJson(jsonData);
}

void executeStartupCommands(AppData appData) async {
  for (var data in appData.startupDataList) {
    print(data.command);
    Future.delayed(Duration(seconds: data.duration), () async {
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
          print(e);
        }
      }
    });
  }
}


class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Installation'),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.home), text: 'Home'),
                // Startup
                Tab(icon: Icon(Icons.rocket), text: 'Startup'),
                // event
                Tab(icon: Icon(Icons.event), text: 'Event'),
              ],
            ),
            actions: [
              IconButton(onPressed: () {
                // save data
                FileManager fileManager = FileManager();
                AppData appData = Provider.of<AppData>(context, listen: false);
                fileManager.saveData(appData);
              }, icon: Icon(Icons.save)),
              IconButton(onPressed: () {
                // save data
                FileManager fileManager = FileManager();
                fileManager.openLocalPathInExplorer();
              }, icon: Icon(Icons.folder_open)),
            ],
          ),
          body: TabBarView(
            children: [
              HomeView(),
              StartupView(),
              EventView(),
            ],
          ),
        )
      ),
    );
  }
}