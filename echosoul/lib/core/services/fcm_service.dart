import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Servicio singleton para gestionar FCM.
class FcmService {
  static final FcmService _instance = FcmService._();
  factory FcmService() => _instance;
  FcmService._();

  static Future<void> initialize() async {
    await Firebase.initializeApp();
    debugPrint('FcmService: Firebase Inicializado');
  }

  Future<bool> requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }
}
