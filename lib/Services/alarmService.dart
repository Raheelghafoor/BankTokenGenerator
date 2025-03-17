import 'dart:io';
import 'dart:math';

import 'package:alarm/alarm.dart';
import 'package:flutter/cupertino.dart';

class AlarmService {
  final List<AlarmSettings> alarmList = [];
  List<AlarmSettings> activeAlarmList = [];

  Future<void> deleteAlarm(int id, BuildContext context) async {
    final alarmItem = await Alarm.getAlarm(id);
    alarmList.remove(alarmItem);
    await Alarm.stop(id);
  }

  void getAlarmList() async{
     activeAlarmList = await Alarm.getAlarms();
  }

  Future<void> saveAlarm(
      BuildContext context, int? alarmId, DateTime dateTime, String tokenNumber) async {
    final alarmSettings = AlarmSettings(
      id: alarmId ?? Random().nextInt(300000),
      dateTime: dateTime,
      assetAudioPath: 'assets/alarm.mp3',
      loopAudio: true,
      vibrate: true,
      warningNotificationOnKill: Platform.isIOS,
      androidFullScreenIntent: true,
      // volume: 0.8,
      // fadeDuration: 5.0,
      // volumeEnforced: true,
      notificationSettings: NotificationSettings(
        title: 'Your Turn',
        body: 'Please reach at the count with token number $tokenNumber',
        stopButton: 'Stop the alarm',
        icon: 'notification_icon',
      ),
    );
    final bool createdSuccessfully = await Alarm.set(
      alarmSettings: alarmSettings,
    );
    alarmList.add(
      alarmSettings,
    );
  }
}
