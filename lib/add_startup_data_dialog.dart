import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

import 'startup_data.dart';
import 'package:flutter/material.dart';


class AddStartupDataDialog extends StatefulWidget {
  final Function(StartupData) onAdd;

  const AddStartupDataDialog({Key? key, required this.onAdd}) : super(key: key);

  @override
  _AddStartupDataDialogState createState() => _AddStartupDataDialogState();
}

class _AddStartupDataDialogState extends State<AddStartupDataDialog> {
  final TextEditingController commandController = TextEditingController();
  final TextEditingController durationController = TextEditingController(text: "0");
  final TextEditingController ipAddressController = TextEditingController(text: "192.168.100.100");
  final TextEditingController portController = TextEditingController(text: "4352");

  String? selectedType = 'app';
  String? selectedPjLinkCommand = 'on';

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
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
    return TextField(
      controller: commandController,
      decoration: InputDecoration(labelText: 'File'),
      onTap: _pickFile,
      readOnly: true,
    );
  } else if (selectedType == 'pjlink') {
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
          value: selectedPjLinkCommand, 
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
              items: ['app', 'pjlink'].map((String value) {
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
            TextField(
              controller: durationController,
              decoration: InputDecoration(labelText: 'Duration(sec)'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly]
            ),
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
            if (selectedType != null && durationController.text.isNotEmpty) {
              final int? duration = int.tryParse(durationController.text);
              if (duration != null) {
                if (selectedType == 'pjlink') {
                  commandController.text = "${ipAddressController.text}:${portController.text} ${selectedPjLinkCommand}";
                }
                if (commandController.text.isEmpty) {
                  return;
                }
                final StartupData data = StartupData(
                  type: selectedType!,
                  command: commandController.text,
                  duration: duration,
                );
                widget.onAdd(data);
                Navigator.of(context).pop();
              }
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}