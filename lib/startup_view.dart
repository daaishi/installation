import 'dart:io';
import 'package:flutter/material.dart';
import 'package:installation/app_data.dart';
import 'package:process_run/shell.dart';
import 'package:provider/provider.dart';
import 'startup_data.dart';
import 'pj_link_service.dart';
import 'add_startup_data_dialog.dart';


class StartupView extends StatefulWidget {
  @override
  _StartupViewState createState() => _StartupViewState();
}

class _StartupViewState extends State<StartupView> {

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
    AppData appData = Provider.of<AppData>(context);
    for (var data in appData.startupDataList) {
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
  }

  void _showAddStartupDataDialog(BuildContext context) {
    AppData appData = Provider.of<AppData>(context, listen: false);
    showDialog(context: context, builder: (BuildContext dialogContext) {
      return AddStartupDataDialog(
        onAdd: (StartupData data) {
          appData.addStartupData(data);
        },
      );
    });
  }

  Widget _buildSimulationButton() {
    return ElevatedButton(
      onPressed: () => _executeCommands(),
      child: Icon(Icons.play_arrow),
    );
  }

  Widget _buildDataTable()
  {

    AppData appData = Provider.of<AppData>(context);

    return DataTable(
      columns: [
        DataColumn(label: Text('Type')),
        DataColumn(label: Text('Command')),
        DataColumn(label: Text('Duration')),
        DataColumn(label: Text('Actions')),
      ],
      rows: appData.startupDataList.map((data) => DataRow(cells: [
        DataCell(Text(data.type)),
        DataCell(Text(data.command)),
        DataCell(Text(data.duration.toString())),
        DataCell(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              appData.removeStartupData(data);
            },
          ),
          IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: () {
              _executeCommand(data);
            },
          ),
        ],
      )),
      ])).toList(),
    );
  }
}


