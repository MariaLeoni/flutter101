import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'notification.dart';


Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

String serverKey = "key=";
const fcmURL = "https://fcm.googleapis.com/fcm/send";


class NotificationManager{
  String? deviceToken;

  void updateToken(String token) async{
    await FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid).update({
      'token': token,
    });
  }

  // For handling notification when the app is in terminated state
  checkForInitialMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      NotificationModel notification = NotificationModel(
        title: initialMessage.notification?.title,
        body: initialMessage.notification?.body,
      );
      print("Initial Messages ${notification.title}");
    }
  }

  void sendNotification(String token, NotificationModel model) async {
    final collection = FirebaseFirestore.instance.collection('cms').doc("aiYFVBMWhZjcBdy4FTwg");
    final cms = await collection.get();
    serverKey = "$serverKey${cms.get("fcm").toString()}";

    try {
      await http.post(Uri.parse(fcmURL),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': serverKey
        },
        body: jsonEncode({
          'to': token,
          'data': {
            'title': model.dataTitle,
            'body': model.dataBody,
          },
          'notification': {
            'title': model.title,
            'body': model.body,
          },
        }),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print("Error sending notif $e");
    }
  }

  void registerDevice() async {
    await FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get().then<dynamic>((DocumentSnapshot snapshot) {
      deviceToken = snapshot.get('token');
    });

    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null && fcmToken != deviceToken) updateToken(fcmToken);
  }

  void initServer() {
    registerDevice();

    // Add the following line
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    checkForInitialMessage();

    // For handling notification when the app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      NotificationModel notification = NotificationModel(
        title: message.notification?.title,
        body: message.notification?.body,
        dataTitle: message.data['title'],
        dataBody: message.data['body'],
      );

      print("Inside App Messages ${notification.title}");
    });

    // For handling notification when the app is in background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      NotificationModel notification = NotificationModel(
        title: message.notification?.title,
        body: message.notification?.body,
        dataTitle: message.data['title'],
        dataBody: message.data['body'],
      );
      print("Opened App Messages ${notification.title}");
    });

    // For handling notification refresh - probably reinstall of app
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      updateToken(fcmToken);
    }).onError((err) {
      print("Error with token ${err.toString()}");
    });
  }
}