
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class LocalNotificationScreen extends StatefulWidget {
  @override
  LocalNotificationScreenState createState() => LocalNotificationScreenState();
}

class LocalNotificationScreenState extends State<LocalNotificationScreen> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notification();
    requestNotificationPermission();
  }



  notification() async {
    print('Notification method called.!');
    var android = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var ios = const IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    var platform = InitializationSettings(android: android, iOS: ios);
    flutterLocalNotificationsPlugin.initialize(platform);
  }

  notificationDetails(String title, String body) async {
    var androidNotification = const AndroidNotificationDetails(
      'CHANNEL ID',
      "CHANNLE NAME",
      importance: Importance.max,
      priority: Priority.max,
      enableLights: true,
      playSound: true,
    );
    var iosNotification = const IOSNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    var platformNotification =
    NotificationDetails(android: androidNotification, iOS: iosNotification);


    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin.show(
        0,
        'Title : $title',
        'Body : $body',
        platformNotification,
      );
    } else {
      await flutterLocalNotificationsPlugin.show(
        0,
        'Title : $title',
        'Body : $body',
        platformNotification,
      );
    }
  }





  void requestNotificationPermission ()async{


    String? a =await FirebaseMessaging.instance.getToken();
    print(a);


/// App is Foreground Call

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (message.notification != null) {
        notificationDetails(message.notification!.title.toString(), message.notification!.body.toString());
        print('Message also contained a notification: ${message.notification}');
      }

      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
               'channel.id',
                'channel.name',
                 icon: android.smallIcon,playSound: true,channelShowBadge: true
                // other properties...
              ),
            ));
      }
    });




  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            notificationDetails('dn ', 'bfgvj');
          },
          child: const Text('Send notification'),
        ),
      ),
    );
  }
}




