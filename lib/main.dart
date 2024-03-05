import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:installation/event_view.dart';
import 'package:installation/file_manager.dart';
import 'package:installation/startup_view.dart';
import 'package:installation/app_data.dart';
import 'package:provider/provider.dart';
import 'home_view.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  FileManager fileManager = FileManager();

  AppData appData = await loadAppData(fileManager);

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