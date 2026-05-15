import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

import '../../features/mood/presentation/screens/mood_tracker_screen.dart';
import '../../features/legal/presentation/screens/legal_screen.dart';

// ── Feature pages (import when created) ──────────────────
import '../../features/landing/presentation/screens/landing_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/companion/presentation/screens/main_layout_screen.dart';
import '../../features/companion/presentation/screens/companion_home_screen.dart';
import '../../features/companion/presentation/screens/chat_screen.dart';
import '../../features/companion/presentation/screens/voice_call_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // Use a notifier to trigger GoRouter refreshes when auth state changes
  // We DON'T watch authStateChangesProvider here anymore to prevent the router from being re-created.
  // Instead, the refreshListenable will notify GoRouter when to re-run the redirect logic.
  
  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    // This is critical: notify GoRouter to re-run redirect when Supabase auth state changes.
    // We listen directly to the Supabase stream to avoid Riverpod's StreamProvider latency/loading states.
    refreshListenable: _GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange),
    redirect: (context, state) {
      final matchedLocation = state.matchedLocation;
      final isLoggingIn = matchedLocation == RouteNames.login;
      final isResettingPassword = matchedLocation == RouteNames.resetPassword;
      final isSplash = matchedLocation == RouteNames.splash;
      final isOnboarding = matchedLocation == RouteNames.onboarding;
      
      // 1. Access auth state SYNCHRONOUSLY
      // This is the most reliable way to avoid flickering during redirects.
      final auth = Supabase.instance.client.auth;
      final supabaseUser = auth.currentUser;
      final hasSession = auth.currentSession != null;
      
      // Map to our UserEntity if we have a user
      final activeUser = supabaseUser != null 
          ? ref.read(authRepositoryProvider).mapSupabaseUser(supabaseUser) 
          : null;

      // 2. Logging for diagnostics
      debugPrint('--- [AUTH ROUTER] ---');
      debugPrint('Target: $matchedLocation');
      debugPrint('User: ${activeUser?.email ?? "NULL"}');
      debugPrint('Session: ${hasSession ? "ACTIVE" : "NONE"}');
      debugPrint('Onboarding: ${activeUser?.onboardingCompleted ?? "N/A"}');
      debugPrint('URI: ${state.uri}');
      
      // 3. Handle OAuth Callback State (PKCE / Implicit)
      final fullUri = state.uri.toString();
      final hasOAuthParams = state.uri.queryParameters.containsKey('code') || 
                            state.uri.fragment.contains('access_token=') ||
                            fullUri.contains('access_token=') ||
                            fullUri.contains('code=');
      
      if (hasOAuthParams && activeUser == null) {
        debugPrint('AUTH ROUTER: OAuth in progress... Blocking redirect.');
        return null; // Stay on current page while Supabase exchanges tokens
      }

      // 4. Recovery Flow (Password Reset)
      final isRecovery = state.uri.fragment.contains('type=recovery') || 
                         state.uri.queryParameters['type'] == 'recovery';
      
      if (isResettingPassword || isRecovery) {
        debugPrint('AUTH ROUTER: Recovery path allowed.');
        return null;
      }

      // 5. Access Control Logic
      
      // Case: NOT Authenticated
      if (activeUser == null) {
        // If we are not on login or splash, force login
        if (!isLoggingIn && !isSplash) {
          debugPrint('AUTH ROUTER: No user -> Redirecting to LOGIN');
          return RouteNames.login;
        }
        return null; // Already on Login or Splash
      }

      // Case: Authenticated
      
      // If we are on Auth-only pages, move to the right place
      if (isLoggingIn || isSplash) {
        if (!activeUser.onboardingCompleted) {
          debugPrint('AUTH ROUTER: Authenticated (New) -> ONBOARDING');
          return RouteNames.onboarding;
        }
        debugPrint('AUTH ROUTER: Authenticated (Existing) -> HOME');
        return RouteNames.companionHome;
      }

      // If we are on Onboarding but already finished it, move to Home
      if (isOnboarding && activeUser.onboardingCompleted) {
        debugPrint('AUTH ROUTER: Onboarding already done -> HOME');
        return RouteNames.companionHome;
      }

      // If we are trying to access protected content but haven't onboarded
      final isTryingProtected = matchedLocation.startsWith(RouteNames.companionHome) || 
                                matchedLocation == RouteNames.mood ||
                                matchedLocation == RouteNames.profile;
                                
      if (isTryingProtected && !activeUser.onboardingCompleted) {
        debugPrint('AUTH ROUTER: Access denied (onboarding required) -> ONBOARDING');
        return RouteNames.onboarding;
      }

      debugPrint('AUTH ROUTER: Path allowed.');
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
          GoRoute(
            path: RouteNames.legal,
            name: RouteNames.legal,
            builder: (context, state) => const LegalScreen(),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        name: RouteNames.resetPassword,
        builder: (context, state) => const ResetPasswordScreen(),
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


/// Temporary placeholder while features are implemented
class _PlaceholderPage extends StatelessWidget {
  final String label;
  const _PlaceholderPage({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FlutterLogo(size: 64),
            const SizedBox(height: 16),
            Text(
              'EchoSoul — $label',
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 32),
            // Only show logout on home/profile placeholders for testing
            if (label == 'Companion Home' || label == 'Profile')
              Consumer(
                builder: (context, ref, child) {
                  return ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await ref.read(authControllerProvider.notifier).signOut();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sesión cerrada correctamente.'),
                              backgroundColor: Color(0xFF0D9488), // EsColors.success
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: const Color(0xFFE11D48), // EsColors.distress
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar Sesión'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E1D2D), // EsColors.surface
                      foregroundColor: const Color(0xFF2DD4BF), // EsColors.neonCyan
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
