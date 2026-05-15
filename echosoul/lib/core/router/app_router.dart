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
  final authState = ref.watch(authStateChangesProvider);
  
  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    // This is critical: notify GoRouter to re-run redirect when authState changes
    refreshListenable: _GoRouterRefreshStream(ref.watch(authRepositoryProvider).authStateChanges),
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == RouteNames.login;
      final isResettingPassword = state.matchedLocation == RouteNames.resetPassword;
      final isSplash = state.matchedLocation == RouteNames.splash;
      
      final isAuthLoading = authState is AsyncLoading;
      final user = authState.value;

      // 1. Log transition for debugging
      debugPrint('AUTH ROUTER: [${state.matchedLocation}] User: ${user?.email ?? 'NULL'}, Loading: $isAuthLoading');
      debugPrint('AUTH ROUTER: Full URI: ${state.uri}');

      // 2. If auth state is still loading, stay/wait
      if (isAuthLoading) {
        debugPrint('AUTH ROUTER: Auth is loading, waiting...');
        return null;
      }

      // 3. If there was an error during auth, log it and redirect to login
      if (authState.hasError) {
        debugPrint('AUTH ROUTER ERROR: ${authState.error}');
        if (!isLoggingIn) return RouteNames.login;
        return null;
      }

      // 4. Detect recovery flow (type=recovery in hash or query)
      final isRecovery = state.uri.fragment.contains('type=recovery') || 
                         state.uri.queryParameters['type'] == 'recovery';
      
      // 5. Detect if we are in an OAuth/PKCE callback flow (URL has code or tokens)
      // We check queryParameters, fragment, and even the full URI string for safety
      final fullUriString = state.uri.toString();
      final hasAuthTokens = state.uri.queryParameters.containsKey('code') || 
                           state.uri.fragment.contains('access_token=') ||
                           fullUriString.contains('access_token=') ||
                           fullUriString.contains('code=');
      
      if (user == null && hasAuthTokens) {
        debugPrint('AUTH ROUTER: Detectado token/código en URL, bloqueando redirección para procesar sesión...');
        return null; // Stay put, Supabase is processing the token
      }

      // 6. If resetting password or in recovery flow, allow it and don't redirect to home
      if (isResettingPassword || isRecovery) return null;

      // 7. If user is NOT logged in and NOT on login page and NOT on splash(landing) page, redirect to login
      if (user == null && !isLoggingIn && !isSplash) {
        debugPrint('AUTH ROUTER: Usuario no autenticado, enviando a Login');
        return RouteNames.login;
      }

      // 8. If user IS logged in and ON login or splash(landing) page, redirect to home
      if (user != null && (isLoggingIn || isSplash)) {
        debugPrint('AUTH ROUTER: Usuario autenticado (${user.email}), redirigiendo a Home/Onboarding');
        if (!user.onboardingCompleted) {
          return RouteNames.onboarding;
        }
        return RouteNames.companionHome;
      }

      // 9. If user IS logged in, but tries to access companionHome while not having completed onboarding
      if (user != null && state.matchedLocation.startsWith(RouteNames.companionHome)) {
         if (!user.onboardingCompleted) {
           debugPrint('AUTH ROUTER: Onboarding pendiente, redirigiendo...');
           return RouteNames.onboarding;
         }
      }

      // Allow navigation
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
    notifyListeners();
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
