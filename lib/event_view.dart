import 'dart:io';
import 'package:flutter/material.dart';
import 'package:installation/add_event_data_dialog.dart';
import 'package:installation/app_data.dart';
import 'package:installation/event_data.dart';
import 'package:installation/windows_service.dart';
import 'package:intl/intl.dart';
import 'package:process_run/shell.dart';
import 'package:provider/provider.dart';
import 'startup_data.dart';
import 'pj_link_service.dart';
import 'add_startup_data_dialog.dart';


class EventView extends StatefulWidget {
  @override
  _EventViewState createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        children: [
          _buildDataTable(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDataDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _executeCommand(EventData data) async {
    if (data.type == 'pjlink') {
      var pjLinkService = PJLinkService(commandString: data.command);
      pjLinkService.executeCommand();
    } else if (data.type == 'system') {
    } else if (data.type == 'app') {
      WindowsService.appControl(data.command);
      // try {
      //   var shell = Shell();
      //   await shell.run('''
      //     cmd /c start "" "${data.command}"
      //   ''');
      // }
      // catch (e) {
      //   print(e);
      // }
    }
  }

  void _showAddDataDialog(BuildContext context) {
    AppData appData = Provider.of<AppData>(context, listen: false);
    showDialog(context: context, builder: (BuildContext dialogContext) {
      return AddEventDataDialog(
        onAdd: (EventData data) {
          appData.addEventData(data);
        },
      );
    });
  }

  Widget _buildDataTable()
  {

    AppData appData = Provider.of<AppData>(context);

    return DataTable(
      columns: [
        DataColumn(label: Text('Type')),
        DataColumn(label: Text('Command')),
        DataColumn(label: Text('Time')),
        DataColumn(label: Text('Actions')),
      ],
      rows: appData.eventDataList.map((data) => DataRow(cells: [
        DataCell(Text(data.type)),
        DataCell(Text(data.command)),
        DataCell(Text(DateFormat('HH:mm:ss').format(data.time))),
        DataCell(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // ここに削除のロジックを追加
              appData.removeEventData(data);
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


