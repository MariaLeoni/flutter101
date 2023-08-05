import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification.dart';


Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

String serverKey = "key=";
const fcmURL = "https://fcm.googleapis.com/fcm/send";


class NotificationManager{
  String? deviceToken;

  void updateToken(String token) async{
    print("Token $token");
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
    await sendPush(token, model);
  }

  void registerDevice() async {
    await FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
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
    });

    // For handling notification when the app is in background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      NotificationModel notification = NotificationModel(
        title: message.notification?.title,
        body: message.notification?.body,
        dataTitle: message.data['title'],
        dataBody: message.data['body'],
      );
    });

    // For handling notification refresh - probably reinstall of app
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      updateToken(fcmToken);
    }).onError((err) {
      print("Error with token ${err.toString()}");
    });
  }

  void alertForNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized || settings.authorizationStatus == AuthorizationStatus.provisional) {
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true, // Required to display a heads up notification
        badge: true,
        sound: true,
      );
      initServer();
      print('User Notification permission ${settings.authorizationStatus}');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  Future<void> sendPush(String token, NotificationModel model) async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'sendByFCMAdmin',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 10),
        )
    );

    try {
      final result = await callable.call(<String, dynamic>{
        'title': model.title,'body': model.body, 'token': token, 'other': "${model.dataTitle}, ${model.dataBody}"
      });
      print("FCM function results ${result.data as String}");
    } catch (e) {
      print("FCM function ERROR: ${e.toString()}");
    }
  }
}