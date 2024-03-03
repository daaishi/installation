import 'package:flutter/material.dart';
import 'add_system_command_dialog.dart';
import 'windows_service.dart';

class SystemView extends StatefulWidget {
  @override
  _SystemViewState createState() => _SystemViewState();
}


class _SystemViewState extends State<SystemView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
          child: DataTable(
            columns: const <DataColumn>[
              DataColumn(label: Text('Command')),
              DataColumn(label: Text('Time')),
              DataColumn(label: Text('Actions')),
            ],
            rows: <DataRow>[
              DataRow(
                cells: <DataCell>[
                  DataCell(Text('Restart')),
                  DataCell(Text('00:00:00')),
                  DataCell(
                    Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.science),
                          onPressed: () {
                            WindowsService.restart();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (BuildContext context) => AddSystemCommandDialog(onAdd: (String command, String time) { 
            print('command: $command, time: $time');
          }
          ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}