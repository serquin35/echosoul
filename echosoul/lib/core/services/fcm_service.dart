import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';
import '../router/route_names.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('FcmService: Mensaje recibido en BACKGROUND: ${message.messageId}');
}

/// Servicio singleton para gestionar FCM.
class FcmService {
  static final FcmService _instance = FcmService._();
  factory FcmService() => _instance;
  FcmService._();

  static void _handleNotificationTap(RemoteMessage message) {
    debugPrint('FcmService: Manejando tap de notificación. Data: ${message.data}');
    
    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      debugPrint('FcmService: No se pudo navegar, context es null');
      return;
    }

    final type = message.data['type'];
    if (type == 'daily_checkin' || type == 'smart_nudge') {
      context.goNamed(RouteNames.chat);
    } else if (type == 'mood_insights') {
      context.goNamed(RouteNames.mood);
    } else {
      context.goNamed(RouteNames.companionHome);
    }
  }

  static Future<void> initialize() async {
    try {
      if (kIsWeb) {
        // On Web, Firebase needs explicit options or to be initialized in index.html.
        // If they are missing, Firebase.initializeApp() crashes.
        // For now, we'll skip it if it fails or if we want to add options later.
        debugPrint('FcmService: Checking Firebase for Web...');
      }
      
      await Firebase.initializeApp();
      debugPrint('FcmService: Firebase Inicializado');

      if (!kIsWeb) {
        // 1. Manejador en segundo plano (Background/Terminated)
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

        // 2. Manejador en primer plano (Foreground)
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('FcmService: Mensaje recibido en FOREGROUND: ${message.notification?.title}');
          // Aquí se integraría flutter_local_notifications si se requiere mostrar el Heads-Up
        });

        // 3. Manejador cuando se hace tap en la notificación (App estaba en background)
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          debugPrint('FcmService: Notificación clickeada (App en BACKGROUND): ${message.notification?.title}');
          _handleNotificationTap(message);
        });
        
        // 4. Manejador cuando la app se abre desde una notificación (App estaba cerrada/Terminated)
        final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
        if (initialMessage != null) {
          debugPrint('FcmService: App iniciada desde notificación (App TERMINADA): ${initialMessage.notification?.title}');
          // Esperamos un frame para asegurar que el router esté listo
          Future.microtask(() => _handleNotificationTap(initialMessage));
        }
      }
    } catch (e) {
      debugPrint('⚠️ FcmService: Firebase could not be initialized. FCM features will be disabled. Error: $e');
      // We don't rethrow to avoid crashing the whole app
    }
  }

  Future<bool> requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  Future<String?> getToken() async {
    try {
      if (Firebase.apps.isEmpty) return null;
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint('⚠️ FcmService: Cannot get token, error: $e');
      return null;
    }
  }
}
