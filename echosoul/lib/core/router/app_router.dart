import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'route_names.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

import '../../features/mood/presentation/screens/mood_tracker_screen.dart';
import '../../features/legal/presentation/screens/legal_screen.dart';

// ── Feature pages ──────────────────
import '../../features/landing/presentation/screens/landing_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/companion/presentation/screens/main_layout_screen.dart';
import '../../features/companion/presentation/screens/companion_home_screen.dart';
import '../../features/companion/presentation/screens/chat_screen.dart';
import '../../features/companion/presentation/screens/voice_call_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/billing/presentation/screens/paywall_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    // Notify GoRouter to re-run redirect when Supabase auth state changes.
    refreshListenable: _GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange),
    redirect: (context, state) {
      final uri = state.uri;
      final path = uri.path;
      
      final isLoggingIn = path == RouteNames.login;
      final isResettingPassword = path == RouteNames.resetPassword;
      final isSplash = path == RouteNames.splash;
      final isOnboarding = path == RouteNames.onboarding;
      final isLegal = path == RouteNames.legal;
      final isPaywall = path == RouteNames.paywall;
      
      // 1. Access auth state SYNCHRONOUSLY
      final auth = Supabase.instance.client.auth;
      final supabaseUser = auth.currentUser;
      
      // Map to our UserEntity if we have a user
      final authRepo = ref.read(authRepositoryProvider);
      final activeUser = supabaseUser != null 
          ? authRepo.mapSupabaseUser(supabaseUser) 
          : null;

      // 2. Logging for diagnostics
      debugPrint('--- [AUTH ROUTER] ---');
      debugPrint('Current Path: $path');
      debugPrint('User: ${activeUser?.email ?? "GUEST"}');
      debugPrint('Onboarding Done: ${activeUser?.onboardingCompleted ?? "N/A"}');
      
      // 3. Handle OAuth Callback State
      final fullUri = uri.toString();
      final hasOAuthParams = uri.queryParameters.containsKey('code') || 
                            uri.fragment.contains('access_token=') ||
                            fullUri.contains('access_token=') ||
                            fullUri.contains('code=');
      
      if (hasOAuthParams && activeUser == null) {
        debugPrint('AUTH ROUTER: OAuth callback in progress... Blocking redirect.');
        return null; 
      }

      // 4. Guest / Public Routes
      final isRecovery = uri.fragment.contains('type=recovery') || 
                         uri.queryParameters['type'] == 'recovery';
                         
      if (isResettingPassword || isRecovery || isLegal || isPaywall) {
        debugPrint('AUTH ROUTER: Public/Recovery path allowed.');
        if (isRecovery && !isResettingPassword) {
          debugPrint('AUTH ROUTER: Recovery detected -> Redirecting to RESET PASSWORD');
          return RouteNames.resetPassword;
        }
        return null;
      }

      // 5. Access Control Logic
      
      // Case: NOT Authenticated
      if (activeUser == null) {
        if (!isLoggingIn && !isSplash) {
          debugPrint('AUTH ROUTER: Guest trying to access protected route -> LOGIN');
          return RouteNames.login;
        }
        return null; 
      }

      // Case: Authenticated
      
      // If we are on Guest-only pages (Splash/Login), move to App or Onboarding
      if (isLoggingIn || isSplash) {
        if (!activeUser.onboardingCompleted) {
          debugPrint('AUTH ROUTER: Auth (New) -> ONBOARDING');
          return RouteNames.onboarding;
        }
        debugPrint('AUTH ROUTER: Auth (Existing) -> HOME');
        return RouteNames.companionHome;
      }

      // If we are on Onboarding but already finished it, move to Home
      if (isOnboarding && activeUser.onboardingCompleted) {
        debugPrint('AUTH ROUTER: Onboarding already done -> HOME');
        return RouteNames.companionHome;
      }

      // If we are trying to access protected content but haven't onboarded
      final isProtected = path.startsWith(RouteNames.companionHome) || 
                          path == RouteNames.mood ||
                          path == RouteNames.profile;
                                 
      if (isProtected && !activeUser.onboardingCompleted) {
        debugPrint('AUTH ROUTER: Onboarding required -> ONBOARDING');
        return RouteNames.onboarding;
      }

      debugPrint('AUTH ROUTER: Target allowed.');
      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: RouteNames.splash,
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainLayoutScreen(child: child);
        },
        routes: [
          GoRoute(
            path: RouteNames.companionHome,
            name: RouteNames.companionHome,
            builder: (context, state) => const CompanionHomeScreen(),
            routes: [
              GoRoute(
                path: 'chat',
                name: RouteNames.chat,
                builder: (context, state) => const ChatScreen(),
              ),
              GoRoute(
                path: 'voice',
                name: RouteNames.voiceCall,
                builder: (context, state) => const VoiceCallScreen(),
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.mood,
            name: RouteNames.mood,
            builder: (context, state) => const MoodTrackerScreen(),
          ),
          GoRoute(
            path: RouteNames.profile,
            name: RouteNames.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.legal,
        name: RouteNames.legal,
        builder: (context, state) => const LegalScreen(),
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        name: RouteNames.resetPassword,
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.paywall,
        name: RouteNames.paywall,
        builder: (context, state) => const PaywallScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Ruta no encontrada: ${state.uri}'),
      ),
    ),
  );
});

/// Helper class to convert a Stream into a Listenable for GoRouter
class _GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  _GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
