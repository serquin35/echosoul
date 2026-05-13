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
}
