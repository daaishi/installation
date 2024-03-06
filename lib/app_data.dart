import 'dart:async';
import 'package:flutter/material.dart';
import 'package:installation/event_data.dart';
import 'package:installation/startup_data.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class AppData extends ChangeNotifier {
  List<StartupData> startupDataList = [];
  List<EventData> eventDataList = [];
  Timer? _timer;

  AppData({
    required this.startupDataList,
    required this.eventDataList,
  });

  void startTimer() {
    logger.i('Timer started');
    if (_timer == null || !_timer!.isActive) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        checkAndExecuteEvents();
      });
    }
  }

  void stopTimer() {
    logger.i('Timer stopped');
    _timer?.cancel();
  }

  void checkAndExecuteEvents() {
    DateTime now = DateTime.now();
    for (var event in eventDataList) {
      DateTime eventTimeToday = DateTime(now.year, now.month, now.day, event.time.hour, event.time.minute, event.time.second);

      if (now.isAfter(eventTimeToday) && (event.lastExecuted == null || event.lastExecuted!.day != now.day)) {
        // TODO: execute command
        logger.e('${event.time} executed: ${event.command}');
        event.lastExecuted = now;
        notifyListeners(); // リスナーに通知
      }
    }
  }

  void addStartupData(StartupData data) {
    startupDataList.add(data);
    startupDataList.sort((a, b) => a.duration.compareTo(b.duration));
    notifyListeners();
  }

  void removeStartupData(StartupData data) {
    startupDataList.remove(data);
    notifyListeners();
  }

  void addEventData(EventData data) {
    DateTime now = DateTime.now();
    DateTime eventTimeToday = DateTime(now.year, now.month, now.day, data.time.hour, data.time.minute, data.time.second);
    if (eventTimeToday.isBefore(now)) {
      data.lastExecuted = DateTime(now.year, now.month, now.day);;
    }

    eventDataList.add(data);
    eventDataList.sort((a, b) => a.time.compareTo(b.time));
    notifyListeners();
  }

  void removeEventData(EventData data) {
    eventDataList.remove(data);
    notifyListeners();
  }


  factory AppData.fromJson(Map<String, dynamic> json) {
    List<StartupData> startupDataList = [];
    List<EventData> eventDataList = [];

    if (json["startupData"] != null) {
      startupDataList = List<StartupData>.from(
        json["startupData"].map((x) => StartupData.fromJson(x))
      );
    }
    if (json["eventData"] != null) {
      eventDataList = List<EventData>.from(
        json["eventData"].map((x) => EventData.fromJson(x))
      );
    }

    // durationに基づいてリストを昇順に並べ替える
    startupDataList.sort((a, b) => a.duration.compareTo(b.duration));
    eventDataList.sort(((a, b) => a.time.compareTo(b.time)));

    // ソートされたリストでAppDataインスタンスを生成
    return AppData(startupDataList: startupDataList, eventDataList: eventDataList);
  }


  Map<String, dynamic> toJson() => {
    "startupData": List<dynamic>.from(startupDataList.map((x)=> x.toJson())),
    "eventData": List<dynamic>.from(eventDataList.map((x) => x.toJson()))
  };
}