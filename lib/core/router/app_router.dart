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
// import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/companion/presentation/screens/main_layout_screen.dart';
import '../../features/companion/presentation/screens/companion_home_screen.dart';
import '../../features/companion/presentation/screens/chat_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
// import '../../features/mood/presentation/pages/mood_tracker_page.dart';
// import '../../features/legal/presentation/pages/legal_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // Watch the auth state to redirect users automatically
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == RouteNames.login;
      final isResettingPassword = state.matchedLocation == RouteNames.resetPassword;
      final isAuthLoading = authState is AsyncLoading;
      final user = authState.value;

      // If auth state is still loading, stay/wait
      if (isAuthLoading) return null;

      // If there was an error during auth (like PKCE failure), log it and redirect to login
      if (authState.hasError) {
        debugPrint('AUTH ROUTER ERROR: ${authState.error}');
        if (!isLoggingIn) return RouteNames.login;
        return null;
      }

      // If resetting password, allow it
      if (isResettingPassword) return null;

      // If user is NOT logged in and NOT on login page, redirect to login
      if (user == null && !isLoggingIn) {
        return RouteNames.login;
      }

      // If user IS logged in and ON login or splash page, redirect to home
      final isSplash = state.matchedLocation == RouteNames.splash;
      if (user != null && (isLoggingIn || isSplash)) {
        if (!user.onboardingCompleted) {
          return RouteNames.onboarding;
        }
        return RouteNames.companionHome;
      }

      // If user IS logged in, but tries to access companionHome while not having completed onboarding
      if (user != null && state.matchedLocation.startsWith(RouteNames.companionHome)) {
         if (!user.onboardingCompleted) {
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
        builder: (context, state) => const _PlaceholderPage(label: 'Splash'),
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
                builder: (context, state) => const _PlaceholderPage(label: 'Voice Call'),
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
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Ruta no encontrada: ${state.uri}'),
      ),
    ),
  );
});

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
