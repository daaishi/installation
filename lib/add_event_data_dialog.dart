import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:installation/custom_time_input.dart';
import 'package:installation/event_data.dart';

import 'package:flutter/material.dart';


class AddEventDataDialog extends StatefulWidget {
  final Function(EventData) onAdd;

  const AddEventDataDialog({Key? key, required this.onAdd}) : super(key: key);

  @override
  _AddEventDataDialogState createState() => _AddEventDataDialogState();
}

class _AddEventDataDialogState extends State<AddEventDataDialog> {
  final TextEditingController commandController = TextEditingController();
  final TextEditingController ipAddressController = TextEditingController(text: "192.168.100.100");
  final TextEditingController portController = TextEditingController(text: "4352");

  String? selectedType = 'app'; // app, system, pjlink
  String? selectedPjLinkCommand = 'on'; // on, off
  String? selectedAppCommand = 'close'; // close, kill
  String? selectedSystemCommand = 'restart'; // restart, shutdown
  String _time = '23:59:59';

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['exe']);
    if (result != null) {
      String? filePath = result.files.single.path;
      if (filePath != null) {
        setState(() {
          commandController.text = filePath;
        });
      }
    }
  }

  Widget _buildCommandInput() {
  if (selectedType == 'app') {
    // 'app'の場合、ファイルピッカーを表示
    return Column(
      children: [
        TextField(
          controller: commandController,
          decoration: InputDecoration(labelText: 'Command'),
          onTap: _pickFile,
          readOnly: true, // ファイルピッカーを使用するため、直接編集は不可
        ),
        DropdownButton<String>(
          value: selectedAppCommand, // コマンド用のコントローラーを流用
          onChanged: (String? newValue) {
            setState(() {
              selectedAppCommand = newValue;
            });
          },
          items: ['close', 'kill'].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  } else if (selectedType == 'system') {
      return DropdownButton<String>(
      value: selectedSystemCommand, // コマンド用のコントローラーを流用
      onChanged: (String? newValue) {
        setState(() {
          commandController.text = newValue!;
          selectedSystemCommand = newValue;
        });
      },
      items: ['restart', 'shutdown'].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );

  } else if (selectedType == 'pjlink') {
    // 'pjlink'の場合、IPアドレス、ポート、コマンド(on/off)を入力
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(labelText: 'IP Address'),
          controller: ipAddressController,
          keyboardType: TextInputType.text,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}(\.\d{0,3}){0,3}$')),
          ],
        ),
        TextField(
          decoration: InputDecoration(labelText: 'Port'),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          controller: portController,
        ),
        DropdownButton<String>(
          value: selectedPjLinkCommand, // コマンド用のコントローラーを流用
          items: ['on', 'off'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              commandController.text = "${ipAddressController.text}:${portController.text}/${newValue}";
              selectedPjLinkCommand = newValue;
            });
          },
        ),
      ],
    );
  } else {
    // その他のtypeが追加された場合のためのデフォルト
    return Container();
  }
}

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add new startup data'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: selectedType,
              items: ['app', 'system', 'pjlink'].map((String value) {
                return DropdownMenuItem<String>(
                  child: Text(value),
                  value: value,
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  selectedType = value;
                  commandController.text = "";
                });
              },
            ),
            _buildCommandInput(),
            CustomTimeInput(onTimeChanged: (time) {
              setState(() {
                _time = time;
              });
              print("Selected time: $_time");
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (selectedType != null && _time.isNotEmpty) {
              String dateTimeString = "0001-01-01 ${_time}";
              final DateTime time = DateTime.parse(dateTimeString);
              if (selectedType == 'pjlink') {
                commandController.text = "${ipAddressController.text}:${portController.text} ${selectedPjLinkCommand}";
              }
              else if (selectedType == 'system') {
                commandController.text = selectedSystemCommand ?? 'restart';
              }
              else if (selectedType == 'app') {
                commandController.text = "-path ${commandController.text} -arg ${selectedAppCommand}";
                print(commandController.text);
              }
              final EventData data = EventData(
                type: selectedType!,
                command: commandController.text,
                time: time,
              );
              widget.onAdd(data);
              Navigator.of(context).pop();
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}