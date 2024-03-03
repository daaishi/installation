import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddSystemCommandDialog extends StatefulWidget{
  final Function(String, String) onAdd;
  AddSystemCommandDialog({required this.onAdd});
  @override
  _AddSystemCommandDialogState createState() => _AddSystemCommandDialogState();
}

class _AddSystemCommandDialogState extends State<AddSystemCommandDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String command = 'Restart';
  String time = '23:59:59';
  final TextEditingController timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    timeController.text = time;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('New Command'),
      content: Form(
        key: formKey,
        child: Column(
          children: <Widget>[
            DropdownButton<String>(
              value: command,
              onChanged: (String? newValue) {
                setState(() {
                  command = newValue ?? '';
                });
              },
              items: <String>['Restart', 'Shutdown'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Time'),
              controller: timeController,
              readOnly: true, // ユーザーが直接テキストフィールドに入力するのを防ぐ
              onTap: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  setState(() {
                    final now = DateTime.now();
                    final pickedDateTime = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
                    time = DateFormat('HH:mm:ss').format(pickedDateTime);
                    timeController.text = time;
                  });
                }
              },
            ),
          ],
        ),
      ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  formKey.currentState?.save();
                  widget.onAdd(command, time);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
    );
  }
}

//   Future<void> show(BuildContext context, Function(String, String) onAdd) {
//     return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('New Command'),
//           content: Form(
//             key: formKey,
//             child: Column(
//               children: <Widget>[
//                 DropdownButton<String>(
//                   value: command,
//                   onChanged: (String? newValue) {
//                     setState(() {
//                       command = newValue ?? '';
//                     });
//                   },
//                   items: <String>['Restart', 'Shutdown'].map<DropdownMenuItem<String>>((String value) {
//                     return DropdownMenuItem<String>(
//                       value: value,
//                       child: Text(value),
//                     );
//                   }).toList(),
//                 ),
//                 TextFormField(
//                   decoration: InputDecoration(labelText: 'Time'),
//                   onSaved: (value) {
//                     time = value ?? '';
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }