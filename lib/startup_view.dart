import 'dart:io';
import 'package:flutter/material.dart';
import 'package:process_run/shell.dart';
import 'startup_data.dart';
import 'pj_link_service.dart';
import 'add_startup_data_dialog.dart';


class StartupView extends StatefulWidget {
  @override
  _StartupViewState createState() => _StartupViewState();
}

class _StartupViewState extends State<StartupView> {

  final List<StartupData> startupData = [
    StartupData(type: 'app', command: 'C:\\Windows\\notepad.exe', duration: 5),
    StartupData(type: 'pjlink', command: '192.168.100.100:4352 off', duration: 0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildSimulationButton(),
          _buildDataTable(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddStartupDataDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _executeCommands() {
    for (var data in startupData) {
      Future.delayed(Duration(seconds: data.duration), (){
        if (data.type == 'pjlink') {
          var pjLinkService = PJLinkService(commandString: data.command);
          pjLinkService.executeCommand();
        } else if (data.type == 'app') {
          Process.run(data.command, []);

        }
      });
    }
  }

  void _executeCommand(StartupData data) async {
    if (data.type == 'pjlink') {
      var pjLinkService = PJLinkService(commandString: data.command);
      pjLinkService.executeCommand();
    } else if (data.type == 'app') {
      // Process.run(data.command, []);
      try {
        var shell = Shell();
        await shell.run('''
          cmd /c start "" "${data.command}"
        ''');
      }
      catch (e) {
        print(e);
      }
    }
  }

  void _showAddStartupDataDialog(BuildContext context) {
    showDialog(context: context, builder: (BuildContext dialogContext) {
      return AddStartupDataDialog(
        onAdd: (StartupData data) {
          setState(() {
            startupData.add(data);
          });
        },
      );
    });
  }

  Widget _buildSimulationButton() {
    return ElevatedButton(
      onPressed: _executeCommands,
      child: Icon(Icons.play_arrow),
    );
  }

  Widget _buildDataTable()
  {
    return DataTable(
      columns: [
        DataColumn(label: Text('Type')),
        DataColumn(label: Text('Command')),
        DataColumn(label: Text('Duration')),
        DataColumn(label: Text('Actions')),
      ],
      rows: startupData.map((data) => DataRow(cells: [
        DataCell(Text(data.type)),
        DataCell(Text(data.command)),
        DataCell(Text(data.duration.toString())),
        DataCell(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // ここに削除のロジックを追加
              setState(() {
                startupData.remove(data);
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: () {
              // ここに実行のロジックを追加
              _executeCommand(data);
            },
          ),
        ],
      )),
      ])).toList(),
    );
  }
}


