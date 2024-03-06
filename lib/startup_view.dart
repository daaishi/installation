import 'package:flutter/material.dart';
import 'package:installation/app_data.dart';
import 'package:installation/execute_service.dart';
import 'package:provider/provider.dart';
import 'startup_data.dart';
import 'add_startup_data_dialog.dart';

class StartupView extends StatefulWidget {
  @override
  _StartupViewState createState() => _StartupViewState();
}

class _StartupViewState extends State<StartupView> {
  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context, listen: false);

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: _buildDataTable(),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            child: const Icon(
              Icons.rocket_launch,
            ),
            onPressed: () {
              ExecuteService.executeStartupCommands(appData.startupDataList);
            },
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            child: const Icon(
              Icons.add,
            ),
            onPressed: () {
              _showAddStartupDataDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showAddStartupDataDialog(BuildContext context) {
    AppData appData = Provider.of<AppData>(context, listen: false);
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AddStartupDataDialog(
            onAdd: (StartupData data) {
              appData.addStartupData(data);
            },
          );
        });
  }

  Widget _buildDataTable() {
    AppData appData = Provider.of<AppData>(context);

    return Container(
      // margin left right bottom
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: SingleChildScrollView(
        child: DataTable(
          columns: [
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Command')),
            DataColumn(label: Text('Duration')),
            DataColumn(label: Text('Actions')),
          ],
          rows: appData.startupDataList
              .map((data) => DataRow(cells: [
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
                            ExecuteService.executeStartupCommand(data);
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
