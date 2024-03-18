import 'dart:convert';
import 'dart:io';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:installation/event_view.dart';
import 'package:installation/execute_service.dart';
import 'package:installation/file_manager.dart';
import 'package:installation/startup_view.dart';
import 'package:installation/app_data.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_view.dart';
import 'package:system_tray/system_tray.dart';

final logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FileManager fileManager = FileManager();

  AppData appData = await loadAppData(fileManager);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isStartupEnabled = prefs.getBool('isStartupEnabled') ?? false;
  bool isEventEnabled = prefs.getBool('isEventEnabled') ?? false;
  if (isStartupEnabled) {
    ExecuteService.executeStartupCommands(appData.startupDataList);
  }
  if (isEventEnabled) {
    appData.startTimer();
  }

  runApp(
    ChangeNotifierProvider<AppData>(
      create: (context) => appData,
      child: MainApp(),
    ),
  );

  doWhenWindowReady(() {
    final initialSize = Size(1280, 720);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.hide();
    // appWindow.show();
  });
}

Future<AppData> loadAppData(FileManager fileManager) async {
  String dataJson = await fileManager.readData();
  Map<String, dynamic> jsonData = json.decode(dataJson);
  return AppData.fromJson(jsonData);
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final AppWindow _appWindow = AppWindow();
  final SystemTray _systemTray = SystemTray();
  final Menu _menuMain = Menu();

  bool _toggleTrayIcon = true;
  bool _toggleMenu = true;

  @override
  void initState() {
    super.initState();
    initSystemTray();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initSystemTray() async {
    await _systemTray.initSystemTray(iconPath: 'assets/app_icon.ico');
    _systemTray.setTitle('Installation');
    _systemTray.setToolTip('Installation');

    _systemTray.registerSystemTrayEventHandler((eventName) {
      if (eventName == kSystemTrayEventClick) {
        appWindow.show();
      } else if (eventName == kSystemTrayEventRightClick) {
        _systemTray.popUpContextMenu();
      }
    });


    await _menuMain.buildFrom(
      [
      MenuItemLabel(
        label: 'Quit',
        enabled: true,
        onClicked: (menuItem) {
          _appWindow.close();
        },
      ),
      ]
    );

    _systemTray.setContextMenu(_menuMain);
  }


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
                IconButton(
                    onPressed: () {
                      // save data
                      FileManager fileManager = FileManager();
                      AppData appData =
                          Provider.of<AppData>(context, listen: false);
                      fileManager.saveData(appData);
                    },
                    icon: Icon(Icons.save)),
                IconButton(
                    onPressed: () {
                      // save data
                      FileManager fileManager = FileManager();
                      fileManager.openLocalPathInExplorer();
                    },
                    icon: Icon(Icons.folder_open)),
              ],
            ),
            body: TabBarView(
              children: [
                HomeView(),
                StartupView(),
                EventView(),
              ],
            ),
          )),
    );
  }
}
