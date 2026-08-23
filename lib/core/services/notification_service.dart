import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initialize() async {
    await _requestPermissions();
    await _setupMessageHandlers();
    await _subscribeToTopic('all_users');
  }

  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('Notification permission: ${settings.authorizationStatus}');
  }

  Future<void> _setupMessageHandlers() async {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedApp);
    _messaging.getInitialMessage().then(_handleInitialMessage);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message: ${message.notification?.title}');
  }

  void _handleOpenedApp(RemoteMessage message) {
    debugPrint('Opened app from notification: ${message.data}');
    _navigateFromMessage(message);
  }

  void _handleInitialMessage(RemoteMessage? message) {
    if (message != null) {
      debugPrint('Initial message: ${message.data}');
      _navigateFromMessage(message);
    }
  }

  void _navigateFromMessage(RemoteMessage message) {
    final data = message.data;
    if (data['type'] == 'new_document' && data['documentId'] != null) {
    } else if (data['type'] == 'document_recovered' && data['documentId'] != null) {
    }
  }

  Future<void> _subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }

  Future<void> sendNewDocumentNotification(String documentId, String title, String location) async {
    try {
      await _firestore.collection('notifications').add({
        'type': 'new_document',
        'documentId': documentId,
        'title': 'Nouveau document: $title',
        'body': 'Un document a été publié à $location',
        'topic': 'all_users',
        'createdAt': FieldValue.serverTimestamp(),
        'sent': false,
      });
    } catch (e) {
      debugPrint('Error creating notification: $e');
    }
  }

  Future<void> sendDocumentRecoveredNotification(String documentId, String title, String finderId) async {
    try {
      await _firestore.collection('notifications').add({
        'type': 'document_recovered',
        'documentId': documentId,
        'title': 'Document récupéré: $title',
        'body': 'Votre document a été trouvé !',
        'userId': finderId,
        'createdAt': FieldValue.serverTimestamp(),
        'sent': false,
      });
    } catch (e) {
      debugPrint('Error creating recovery notification: $e');
    }
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  Future<void> saveTokenToUser(String userId, String token) async {
    await _firestore.collection('users').doc(userId).update({
      'fcmToken': token,
      'tokenUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setupUserToken() async {
    final user = _auth.currentUser;
    if (user != null) {
      final token = await getToken();
      if (token != null) {
        await saveTokenToUser(user.uid, token);
      }
    }
  }
}