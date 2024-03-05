import 'package:flutter/material.dart';
import 'package:installation/startup_view.dart';
import 'home_view.dart';
import 'system_view.dart';

void main() async{
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Installtion'),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.home), text: 'Home'),
                // Startup
                Tab(icon: Icon(Icons.business), text: 'Startup'),
                // event
                Tab(icon: Icon(Icons.event), text: 'Event'),
                // system
                Tab(icon: Icon(Icons.settings), text: 'System'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              HomeView(),
              StartupView(),
              Icon(Icons.directions_bike),
              SystemView(),
            ],
          ),
        )
      ),
    );
  }
}