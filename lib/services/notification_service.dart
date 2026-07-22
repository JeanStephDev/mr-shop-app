import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/navigation_service.dart';
import 'auth_service.dart';

/// Initialise Firebase Cloud Messaging + les notifications locales (pour
/// afficher une bannière quand l'app est au premier plan — FCM seul ne le
/// fait pas sur Android), et gère le tap sur une notification pour ouvrir
/// directement la commande concernée.
class NotificationService {
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'mr_shop_orders',
    'Commandes MR Shop',
    description: 'Notifications de suivi de commande',
    importance: Importance.high,
  );

  static Future<void> initialize() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    await _initLocalNotifications();

    final token = await _messaging.getToken();
    if (token != null) {
      await AuthService().updateFcmToken(token);
    }
    _messaging.onTokenRefresh.listen((newToken) => AuthService().updateFcmToken(newToken));

    // App au premier plan : FCM ne montre rien tout seul -> on affiche nous-mêmes.
    FirebaseMessaging.onMessage.listen(_showLocalNotification);

    // L'utilisateur tape sur la notification (app en arrière-plan) -> on navigue.
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // App totalement fermée, ouverte via une notification -> même logique.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  static Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (response) {
        final orderId = int.tryParse(response.payload ?? '');
        if (orderId != null) NavigationService.goToOrderTracking(orderId);
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  static void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(_channel.id, _channel.name, channelDescription: _channel.description, importance: Importance.high, priority: Priority.high),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message.data['order_id'],
    );
  }

  static void _handleNotificationTap(RemoteMessage message) {
    final orderId = int.tryParse(message.data['order_id'] ?? '');
    if (orderId != null) NavigationService.goToOrderTracking(orderId);
  }
}
