import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:push_noti/notification_services.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractedMessage(context);
    notificationServices.getDeviceToken().then((value) => print(value));
    notificationServices.isTokenRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(onPressed: () {
          notificationServices.getDeviceToken().then((value) async {
            var data = {
              'to' : value.toString(),
              'priority' : 'high',
              'notification' : {
                'title' : 'Sinister Chill',
                'body' : 'How are you ?',
              },
              // For directing the screen when on tap on the notification
              'data' : {
                'type' : 'msg',
                'id' : '123'
              },
            };
            await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
                body: jsonEncode(data),
                headers: {
                  "Content-Type": "application/json; charset=UTF-8",
                  "Authorization": "Your key"
                }
            );
          });
        }, child: const Text("Send Notifications")),
      ),
    );
  }
}
