import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'Screen/homePage.dart';
import 'Services/notificationService.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init();
  await NotificationService.init();
  await Permission.scheduleExactAlarm.request();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Token Reminder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const Homepage(),
    );
  }
}