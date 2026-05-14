import 'package:flutter/foundation.dart';

/// Servicio singleton para gestionar FCM (Mocked por ahora).
class FcmService {
  static final FcmService _instance = FcmService._();
  factory FcmService() => _instance;
  FcmService._();

  /// Inicialización simulada
  static Future<void> initialize() async {
    debugPrint('FcmService (Mock): Inicializado');
  }

  /// Petición de permisos simulada
  Future<bool> requestPermission() async {
    debugPrint('FcmService (Mock): requestPermission = true');
    return true;
  }

  /// Devuelve un token simulado para probar flujos en n8n
  Future<String?> getToken() async {
    debugPrint('FcmService (Mock): getToken llamado');
    return 'mock_fcm_token_device_001'; 
  }
}
