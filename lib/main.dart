import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:triptourapp/authen/login.dart';
import 'package:triptourapp/notificationcheck/friendrequest.dart';
import 'package:triptourapp/notificationcheck/tripinvite.dart';
import 'package:triptourapp/service/notification.dart';
import 'main/bottom_navbar.dart';
import 'main/top_navbar.dart';
import 'main/tripbutton.dart';
import 'main/triphistory.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'your_channel_id',
  'your_channel_name',
  description: 'your_channel_description',
  importance: Importance.high,
);

Future<void> _requestPermissionToUser() async {
  await Permission.notification.status;
  // var notificationStatus = await Permission.notification.status;
  // if (notificationStatus.isDenied) {
  //   await Permission.notification.request();
  // }
}

Future<void> _setForegroundNotification() async {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  await firebaseMessaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}

Future<void> _setupLocalNotifications() async {
  var initializationSettingsAndroid =
      const AndroidInitializationSettings('flutter_icon');
  var initializationSettingsIOS = const DarwinInitializationSettings();
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

void _setupForegroundNotificationListener() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    await Firebase.initializeApp();
    _showNotification(message);
  });
}

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  _showNotification(message);
}

Future<void> _showNotification(RemoteMessage message) async {
  // final Map<String, dynamic> data = jsonDecode(message.data['default']);
  // final Map<String, dynamic> gcmNotification = data['GCM']['notification'];
  String? title = message.notification?.title; // Access title
  String? body = message.notification?.body; // Access body
  // final Map<String, dynamic> gcmData = data['GCM']['data'];

  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    channel.id,
    channel.name,
    channelDescription: channel.description,
    importance: Importance.high,
    priority: Priority.high,
  );

  var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );
  if (title != 'Chat')
    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      title,
      body,
      platformChannelSpecifics,
      payload: 'Notification Payload',
    );
}

void main() async {
  initializeDateFormatting('th', null);
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessageHandler);

  await _requestPermissionToUser();
  await _setForegroundNotification();
  await _setupLocalNotifications();
  _setupForegroundNotificationListener();

  runApp(
    MaterialApp(
      home: AuthenticationWrapper(),
    ),
  );
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        try {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          } else {
            if (snapshot.hasData) {
              return MyApp();
            } else {
              return LoginPage();
            }
          }
        } catch (error) {
          print("Error: $error");
        }

        return Container();
      },
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TripTour',
      home: Scaffold(
        appBar: TopNavbar(),
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Column(
            children: [
              TripButtons(),
              TripHistory(),
              inviteCheck(),
              friendinviteCheck(),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavbar(
          selectedIndex: 0,
          onItemTapped: (index) {},
        ),
      ),
    );
  }
}
