class StartupData {
  final String type;
  final String command;
  final int duration;

  StartupData({required this.type, required this.command, required this.duration});

  Map<String, dynamic> toJson() => {
    'type': type,
    'command': command,
    'duration': duration,
  };

  factory StartupData.fromJson(Map<String, dynamic> json) => StartupData(
    type: json['type'],
    command: json['command'],
    duration: json['duration'] ?? 0,
  );
}

