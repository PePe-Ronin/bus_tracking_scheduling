import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Initialize notifications
  Future<void> initialize() async {
    // Request permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _localNotifications.initialize(initializationSettings);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Background message handler
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print('Handling background message: ${message.messageId}');
  }

  // Show local notification
  void _showLocalNotification(RemoteMessage message) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'bus_tracking_channel',
      'Bus Tracking Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    _localNotifications.show(
      0,
      message.notification?.title ?? 'Bus Tracking',
      message.notification?.body ?? 'New notification',
      platformChannelSpecifics,
    );
  }

  // Send notification to specific user
  Future<void> sendNotificationToUser(String userId, String title, String body,
      Map<String, dynamic> data) async {
    // Get user's FCM token
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();
    String? token = userDoc.get('fcmToken');

    if (token != null) {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'body': body,
        'data': data,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });
    }
  }

  // Send bus arrival notification
  Future<void> sendBusArrivalNotification(
      String userId, String busId, String busName, String stopName) async {
    await sendNotificationToUser(
      userId,
      'Bus Arriving',
      '$busName is arriving at $stopName',
      {
        'type': 'bus_arrival',
        'busId': busId,
        'stopName': stopName,
      },
    );
  }

  // Send emergency notification
  Future<void> sendEmergencyNotification(
      String userId, String message, String busId) async {
    await sendNotificationToUser(
      userId,
      'Emergency Alert',
      message,
      {
        'type': 'emergency',
        'busId': busId,
      },
    );
  }

  // Send delay notification
  Future<void> sendDelayNotification(
      String userId, String busId, String busName, int delayMinutes) async {
    await sendNotificationToUser(
      userId,
      'Bus Delay',
      '$busName is delayed by $delayMinutes minutes',
      {
        'type': 'delay',
        'busId': busId,
        'delayMinutes': delayMinutes,
      },
    );
  }

  // Get user notifications
  Stream<List<Map<String, dynamic>>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
  }

  // Subscribe to bus updates
  Future<void> subscribeToBusUpdates(String busId) async {
    await _messaging.subscribeToTopic('bus_$busId');
  }

  // Unsubscribe from bus updates
  Future<void> unsubscribeFromBusUpdates(String busId) async {
    await _messaging.unsubscribeFromTopic('bus_$busId');
  }

  // Get FCM token
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  // Save FCM token to user profile
  Future<void> saveTokenToUserProfile(String userId, String token) async {
    await _firestore.collection('users').doc(userId).update({
      'fcmToken': token,
    });
  }
}
