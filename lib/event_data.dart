class EventData {
  final String type;
  final String command;
  final DateTime time; // DateTime型を使用して秒も含めた時刻を管理
  DateTime? lastExecuted;

  EventData({
    required this.type,
    required this.command,
    required this.time,
    this.lastExecuted
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'command': command,
    // DateTimeをISO8601形式の文字列に変換
    'time': time.toIso8601String(),
  };

  factory EventData.fromJson(Map<String, dynamic> json) => EventData(
    type: json['type'],
    command: json['command'],
    time: DateTime.parse(json['time']),
    lastExecuted: DateTime.now(),
  );
}
