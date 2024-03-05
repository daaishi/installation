class EventData {
  final String type;
  final String command;
  final DateTime time; // DateTime型を使用して秒も含めた時刻を管理

  EventData({
    required this.type,
    required this.command,
    required this.time,
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
    // 文字列からDateTimeオブジェクトを生成
    time: DateTime.parse(json['time']),
  );
}
