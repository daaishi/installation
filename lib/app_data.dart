import 'package:flutter/material.dart';
import 'package:installation/startup_data.dart';

class AppData extends ChangeNotifier {
  List<StartupData> startupDataList = [];

  AppData({
    required this.startupDataList,
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

  // factory AppData.fromJson(Map<String, dynamic> json) => AppData(
  //   startupDataList: List<StartupData>.from(json["startupData"].map((x) => StartupData.fromJson(x)))
  // );

  factory AppData.fromJson(Map<String, dynamic> json) {
    // JSONからリストを生成
    var startupDataList = List<StartupData>.from(
      json["startupData"].map((x) => StartupData.fromJson(x))
    );

    // durationに基づいてリストを昇順に並べ替える
    startupDataList.sort((a, b) => a.duration.compareTo(b.duration));

    // ソートされたリストでAppDataインスタンスを生成
    return AppData(startupDataList: startupDataList);
  }


  Map<String, dynamic> toJson() => {
    "startupData": List<dynamic>.from(startupDataList.map((x)=> x.toJson())),
  };
}