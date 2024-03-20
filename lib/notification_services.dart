import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart%20';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'message_screen.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permission');
      }
    } else
    if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('User granted provisional permission');
      }
    } else {
      AppSettings.openAppSettings();
      if (kDebugMode) {
        print('User declined or has not accepted permission');
      }
    }
  }

  void initLocalNotifications(BuildContext context,
      RemoteMessage message) async {
    var androidInitialization = const AndroidInitializationSettings(
        '@mipmap/ic_launcher');
    var iosInitialization = const DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
        android: androidInitialization, iOS: iosInitialization);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) async {
      handleMessage(context, message);
        });
  }


  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      if(Platform.isAndroid){
        initLocalNotifications(context, message);
        showNotifications(message);
      }
      if (kDebugMode) {
        print(message.notification!.title.toString());
        print(message.data['type'].toString());
        print(message.data['id'].toString());
      }
      if (kDebugMode) {
        print(message.notification!.body.toString());
      }
      else {
        showNotifications(message);
      }
    });
  }

  Future<void> showNotifications(RemoteMessage message) async {

    AndroidNotificationChannel channel = AndroidNotificationChannel(
      Random.secure().nextInt(1000).toString(),
      'High Importance Notifications',
      importance: Importance.max,
    );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        channel.id.toString(),
        channel.name.toString(),
        channelDescription: 'Your channel description',
        importance: Importance.high,
        priority: Priority.high,
      ticker: 'ticker'
    );

    DarwinNotificationDetails darwinNotificationDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails
    );

    Future.delayed(Duration.zero, (){
      flutterLocalNotificationsPlugin.show(
        0,
        message.notification!.title.toString(),
        message.notification!.body.toString(),
        notificationDetails,
      );
    }
    );
  }

  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token!;
  }

  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      if (kDebugMode) {
        print('Token Refreshed');
      }
    });
  }


  Future<void> setupInteractedMessage(BuildContext context) async {

    // when app is in background
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if(initialMessage != null){
      handleMessage(context, initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleMessage(context, message);
    });
  }

  void handleMessage(BuildContext context, RemoteMessage message){
    if(message.data['type'] == 'msg') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => MessageScreen(id: message.data['id'],)));
    }
  }

}