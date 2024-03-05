import 'package:flutter/material.dart';
import 'package:installation/event_data.dart';
import 'package:installation/startup_data.dart';

class AppData extends ChangeNotifier {
  List<StartupData> startupDataList = [];
  List<EventData> eventDataList = [];

  AppData({
    required this.startupDataList,
    required this.eventDataList,
  });

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