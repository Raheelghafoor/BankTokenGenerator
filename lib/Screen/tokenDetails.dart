import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:token_reminder/Services/alarmService.dart';
import 'package:token_reminder/Services/notificationService.dart';

class TokenDetails extends StatefulWidget {
  TokenDetails({super.key, required this.serviceName});
  String serviceName;

  @override
  State<TokenDetails> createState() => _TokenDetailsState();
}

class _TokenDetailsState extends State<TokenDetails> {
  String time = '';
  String token = '';
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    createToken();
  }

  Future<void> createToken() async {
    await NotificationService.init();
    await Permission.scheduleExactAlarm.request();
    const String url =
        "https://mfarhanakram.eu.pythonanywhere.com/create-token/";
    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    final Map<String, dynamic> body = {
      "user_name": "John Doe",
      "description": "fhgfddfdgf"
    };

    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      print("${response.statusCode}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print(" =-=-=-=-=-= $data ");
        if (data.containsKey('success') && data['success'] == true) {
          setState(() {
            token = data['token'] ?? 'N/A';
            String formatedTime = DateFormat("d MMM yyyy hh:mm a").format(
                DateTime.parse(
                        data['assigned_time'] ?? DateTime.now().toString())
                    .toLocal());
            time = formatedTime;
          });
          DateTime alarmTime = DateTime.parse(
              data['assigned_time'] ?? DateTime.now().toString())
              .toLocal();

          print("Time to Set Alarm: $alarmTime");
          print("Token Created: $token");
          print("Assigned Time: $time");
          await NotificationService.showScheduledNotification(
            id: 1,
            title: "Reminder",
            body: "Your appointment is coming up! with Token $token",
            scheduledTime: alarmTime, // 20 sec later
          );
          await AlarmService().saveAlarm(context,null,alarmTime,token);
          await NotificationService.showInstantNotification(
            id: 2,
            title: "Token Number",
            body: "Your token number [ $token ] for appointment at $time",
          );
        } else {
          print(
              "Failed to create token: ${data['message'] ?? 'Unknown error'}");
        }
      } else {
        print("Server Error: ${response.statusCode} - ${response.body}");
      }
    } on FormatException catch (e) {
      print("Invalid JSON format: $e");
    } on http.ClientException catch (e) {
      print("HTTP error: $e");
    } on Exception catch (e) {
      print("Unexpected error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.red,
          centerTitle: true,
          title: const Text(
            "Token Detail",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.red,
                ),
              )
            : Center(
          child: Container(
            width: size.width * 0.9,
            padding: EdgeInsets.all(size.width * 0.05),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Service Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Service Name",
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                        fontSize: size.width * 0.04,
                      ),
                    ),
                    Text(
                      widget.serviceName,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: size.width * 0.05,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.03),

                // Time to Turn to Booth
                Column(
                  children: [
                    Icon(LucideIcons.clock, color: Colors.blue, size: size.width * 0.08),
                    SizedBox(height: 5),
                    Text(
                      "Time to Turn to Booth",
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                        fontSize: size.width * 0.045,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: size.width * 0.07,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.03),

                // Token Number
                Column(
                  children: [
                    Icon(LucideIcons.ticket, color: Colors.green, size: size.width * 0.08),
                    SizedBox(height: 5),
                    Text(
                      "Token Number",
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                        fontSize: size.width * 0.045,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      token,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: size.width * 0.1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
    );
  }
}
