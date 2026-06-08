import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get supabaseUrl =>
      const String.fromEnvironment('SUPABASE_URL').isNotEmpty
          ? const String.fromEnvironment('SUPABASE_URL')
          : dotenv.env['SUPABASE_URL'] ?? '';

  static String get supabaseAnonKey =>
      const String.fromEnvironment('SUPABASE_ANON_KEY').isNotEmpty
          ? const String.fromEnvironment('SUPABASE_ANON_KEY')
          : dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static String? get authRedirectUrl =>
      const String.fromEnvironment('AUTH_REDIRECT_URL').isNotEmpty
          ? const String.fromEnvironment('AUTH_REDIRECT_URL')
          : dotenv.env['AUTH_REDIRECT_URL'];

  /// n8n webhook URL for the EchoSoul chat workflow.
  /// Set this in your .env file as N8N_CHAT_WEBHOOK_URL or via --dart-define.
  static String get n8nChatWebhookUrl =>
      const String.fromEnvironment('N8N_CHAT_WEBHOOK_URL').isNotEmpty
          ? const String.fromEnvironment('N8N_CHAT_WEBHOOK_URL')
          : dotenv.env['N8N_CHAT_WEBHOOK_URL'] ?? '';

  /// Google Web Client ID for native Google Sign-In.
  static String get googleWebClientId =>
      const String.fromEnvironment('GOOGLE_WEB_CLIENT_ID').isNotEmpty
          ? const String.fromEnvironment('GOOGLE_WEB_CLIENT_ID')
          : dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';

  /// Vapi.ai public key for voice calls (WebRTC in-app).
  /// Only the PUBLIC key goes in the client app — NEVER the private key.
  static String get vapiPublicKey =>
      const String.fromEnvironment('VAPI_PUBLIC_KEY').isNotEmpty
          ? const String.fromEnvironment('VAPI_PUBLIC_KEY')
          : dotenv.env['VAPI_PUBLIC_KEY'] ?? '';

  /// Vapi.ai Assistant ID for the EchoSoul companion voice agent.
  static String get vapiAssistantId =>
      const String.fromEnvironment('VAPI_ASSISTANT_ID').isNotEmpty
          ? const String.fromEnvironment('VAPI_ASSISTANT_ID')
          : dotenv.env['VAPI_ASSISTANT_ID'] ?? '';

  /// Validates that all Vapi configuration is present.
  /// Call this before initializing VapiClient to get a clear error message.
  static String validatedVapiPublicKey() {
    final key = vapiPublicKey;
    if (key.isEmpty) {
      throw Exception(
        'VAPI_PUBLIC_KEY is not configured. '
        'Set it in .env or pass --dart-define=VAPI_PUBLIC_KEY=<key> during build.',
      );
    }
    return key;
  }

  /// Validates Vapi Assistant ID.
  static String validatedVapiAssistantId() {
    final id = vapiAssistantId;
    if (id.isEmpty) {
      throw Exception(
        'VAPI_ASSISTANT_ID is not configured. '
        'Set it in .env or pass --dart-define=VAPI_ASSISTANT_ID=<id> during build.',
      );
    }
    return id;
  }
}
