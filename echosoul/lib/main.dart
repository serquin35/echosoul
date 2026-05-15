import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_web_plugins/url_strategy.dart'; // Add this
import 'package:intl/date_symbol_data_local.dart';
import 'core/router/app_router.dart';
import 'core/router/route_names.dart';
import 'core/theme/app_theme.dart';
import 'core/config/env.dart';
import 'core/services/fcm_service.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize date formatting for intl
  await initializeDateFormatting('es_ES', null);
  
  // Enable clean URLs on web (no #)
  usePathUrlStrategy();
  
  await dotenv.load(fileName: ".env");

  // Inicializar FCM
  await FcmService.initialize();

  // Diagnostic logs for Production (Safe info only)
  final webhook = Env.n8nChatWebhookUrl;
  debugPrint('🔧 Env: Webhook is ${webhook.isEmpty ? 'EMPTY' : 'CONFIGURED'}');
  if (webhook.isNotEmpty) {
    debugPrint('🔧 Env: Webhook starts with: ${webhook.substring(0, 10)}...');
  }
  
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  // Diagnostic: Check if we already have a session or if we are recovering one
  final session = Supabase.instance.client.auth.currentSession;
  debugPrint('🚀 Supabase Init: Session is ${session != null ? 'ACTIVE' : 'NULL'}');
  if (session != null) {
    debugPrint('🚀 Supabase Init: User is ${session.user.email}');
  }


  runApp(
    const ProviderScope(
      child: EchoSoulApp(),
    ),
  );
}

class EchoSoulApp extends ConsumerWidget {
  const EchoSoulApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    // Listen for auth events (like password recovery)
    ref.listen(authEventsProvider, (previous, next) {
      next.whenData((data) {
        if (data.event == AuthChangeEvent.passwordRecovery) {
          debugPrint('EVENTO RECUPERACION DETECTADO: Redirigiendo a ResetPassword');
          router.go(RouteNames.resetPassword);
        }
      });
    });

    // Sincronización automática de FCM Token al iniciar sesión
    ref.listen(authStateChangesProvider, (previous, next) {
      next.whenData((user) async {
        if (user != null) {
          debugPrint('Main: Usuario detectado (${user.email}), sincronizando FCM...');
          final token = await FcmService().getToken();
          if (token != null) {
            await ref.read(authRepositoryProvider).updateFcmToken(token);
          }
        }
      });
    });


    return MaterialApp.router(
      title: 'EchoSoul',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
