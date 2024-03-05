import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTimeInput extends StatefulWidget {
  final Function(String time) onTimeChanged;

  CustomTimeInput({required this.onTimeChanged});

  @override
  _CustomTimeInputState createState() => _CustomTimeInputState();
}

class _CustomTimeInputState extends State<CustomTimeInput> {
  final TextEditingController _hourController = TextEditingController(text: "23");
  final TextEditingController _minuteController = TextEditingController(text: "59");
  final TextEditingController _secondController = TextEditingController(text: "59");

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _secondController.dispose();
    super.dispose();
  }

  void _updateTime() {
    String formattedTime =
        '${_hourController.text.padLeft(2, '0')}:${_minuteController.text.padLeft(2, '0')}:${_secondController.text.padLeft(2, '0')}';
    widget.onTimeChanged(formattedTime);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        // 時間入力
        Expanded(
          child: TextField(
            controller: _hourController,
            decoration: InputDecoration(labelText: 'HH'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            onChanged: (_) => _updateTime(),
          ),
        ),
        SizedBox(width: 10), // 余白
        // 分入力
        Expanded(
          child: TextField(
            controller: _minuteController,
            decoration: InputDecoration(labelText: 'MM'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            onChanged: (_) => _updateTime(),
          ),
        ),
        SizedBox(width: 10), // 余白
        // 秒入力
        Expanded(
          child: TextField(
            controller: _secondController,
            decoration: InputDecoration(labelText: 'SS'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            onChanged: (_) => _updateTime(),
          ),
        ),
      ],
    );
  }
}

