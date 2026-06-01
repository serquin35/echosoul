import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_web_plugins/url_strategy.dart'; // Add this
import 'package:intl/date_symbol_data_local.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/config/env.dart';
import 'core/services/fcm_service.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/providers/locale_provider.dart';

const _kLangKey = 'preferred_language';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    usePathUrlStrategy(); // ← MOVER AQUÍ, primera línea
    debugPrint('🚀 APP START: WidgetsBinding initialized');
    
    try {
   
      // Initialize date formatting for intl
      await initializeDateFormatting('es_ES', null);
      await initializeDateFormatting('en_US', null);
      debugPrint('🚀 APP START: Date formatting initialized');
      
      await dotenv.load(fileName: ".env");
      debugPrint('🚀 APP START: .env loaded');

      // Load locale BEFORE app builds para evitar rebuild de MaterialApp.router
      final prefs = await SharedPreferences.getInstance();
      final initialLangCode = prefs.getString(_kLangKey) ?? 'es';
      debugPrint('🚀 APP START: Locale loaded: $initialLangCode');

      // Diagnostic logs for Production (Safe info only)
      final webhook = Env.n8nChatWebhookUrl;
      debugPrint('🔧 Env: Webhook is ${webhook.isEmpty ? 'EMPTY' : 'CONFIGURED'}');
      
      debugPrint('🚀 APP START: Initializing Supabase...');
      await Supabase.initialize(
        url: Env.supabaseUrl,
        anonKey: Env.supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce, // ← CAMBIAR de implicit a pkce
        ),
      );
      debugPrint('🚀 APP START: Supabase initialized');

      // FCM/Firebase DESPUÉS de Supabase
      await FcmService.initialize();
      debugPrint('🚀 APP START: FCM initialized');

      // Diagnostic: Check if we already have a session or if we are recovering one
      final session = Supabase.instance.client.auth.currentSession;
      debugPrint('🚀 Supabase Session: ${session != null ? 'ACTIVE (${session.user.email})' : 'NULL'}');

      runApp(
        ProviderScope(
          overrides: [
            localeProvider.overrideWith((ref) => LocaleNotifier(Locale(initialLangCode))),
          ],
          child: const EchoSoulApp(),
        ),
      );
    } catch (e, stack) {
      debugPrint('❌ CRITICAL STARTUP ERROR: $e');
      debugPrint('❌ STACKTRACE: $stack');
      // Show a basic error app if initialization fails completely
      runApp(MaterialApp(home: Scaffold(body: Center(child: Text('Error al iniciar: $e')))));
    }
  }, (error, stack) {
    debugPrint('❌ UNHANDLED GLOBAL ERROR: $error');
    debugPrint('❌ STACKTRACE: $stack');
  });
}

class EchoSoulApp extends ConsumerWidget {
  const EchoSoulApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);

    // Note: Password recovery navigation is now handled entirely within app_router.dart's redirect logic.
    // This avoids race conditions between Riverpod listeners and GoRouter's state machine.

    // Sincronización automática de FCM Token al iniciar sesión
    ref.listen(authStateChangesProvider, (previous, next) {
      next.whenData((user) async {
        if (user != null) {
          debugPrint('Main: Usuario detectado (${user.email}), solicitando permisos y sincronizando FCM...');
          final hasPermission = await FcmService().requestPermission();
          if (hasPermission) {
            final token = await FcmService().getToken();
            if (token != null) {
              await ref.read(authRepositoryProvider).updateFcmToken(token);
            }
          } else {
            debugPrint('Main: Permiso FCM denegado por el usuario.');
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
      locale: locale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'), // Español
        Locale('en'), // English
      ],
      routerConfig: router,
    );
  }
}
