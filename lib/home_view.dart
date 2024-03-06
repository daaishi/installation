import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:installation/app_data.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

// display current time and date for tab 1
class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool isStartupEnabled = false;
  bool isEventEnabled = false;

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  void loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isStartupEnabled = prefs.getBool('isStartupEnabled') ?? false;
      isEventEnabled = prefs.getBool('isEventEnabled') ?? false;
    });
  }

  void savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isStartupEnabled', isStartupEnabled);
    prefs.setBool('isEventEnabled', isEventEnabled);
  }



  @override
  Widget build(BuildContext context) {

    AppData appData = Provider.of<AppData>(context);

    return Scaffold(
      body: Center(
        child:SizedBox(
          width: 320,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1), (i) => DateTime.now()),
              builder: (context, snapshot) {
                return Text(
                  snapshot.data != null ? DateFormat('yyyy-MM-dd hh:mm:ss').format(snapshot.data!) : 'Loading...',
                  style: const TextStyle(fontSize: 24),
                );
              },
            ),
            SwitchListTile(
              title: const Text('Startup'),
              value: isStartupEnabled,
              onChanged: (bool value) {
                setState(() {
                  isStartupEnabled = value;
                });
                savePreferences();
              },
            ),
            SwitchListTile(
              title: const Text('Event'),
              value: isEventEnabled,
              onChanged: (bool value) {
                setState(() {
                  isEventEnabled = value;
                });
                if (value) {
                  appData.startTimer();
                } else {
                  appData.stopTimer();
                }
                savePreferences();
              },
            ),
          ],
        ),
      ),
      ),
    );
  }
}