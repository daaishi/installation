import 'package:flutter/material.dart';
import 'package:installation/add_event_data_dialog.dart';
import 'package:installation/app_data.dart';
import 'package:installation/event_data.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:installation/execute_service.dart';

class EventView extends StatefulWidget {
  @override
  _EventViewState createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: _buildDataTable(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDataDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddDataDialog(BuildContext context) {
    AppData appData = Provider.of<AppData>(context, listen: false);
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AddEventDataDialog(
            onAdd: (EventData data) {
              appData.addEventData(data);
            },
          );
        });
  }

  Widget _buildDataTable() {
    AppData appData = Provider.of<AppData>(context);

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: SingleChildScrollView(
        child: DataTable(
          columns: [
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Command')),
            DataColumn(label: Text('Time')),
            DataColumn(label: Text('Actions')),
          ],
          rows: appData.eventDataList
              .map((data) => DataRow(cells: [
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
                            ExecuteService.executeEventCommand(data);
                          },
                        ),
                      ],
                    )),
                  ]))
              .toList(),
        ),
      ),
    );
  }
}
