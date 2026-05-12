import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String? get authRedirectUrl => dotenv.env['AUTH_REDIRECT_URL'];

  /// n8n webhook URL for the EchoSoul chat workflow.
  /// Set this in your .env file as N8N_CHAT_WEBHOOK_URL.
  static String get n8nChatWebhookUrl =>
      dotenv.env['N8N_CHAT_WEBHOOK_URL'] ?? '';
}
