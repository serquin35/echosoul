import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/es_colors.dart';
import '../../../../core/constants/es_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/design_system/atoms/es_button.dart';
import '../../../../shared/design_system/atoms/es_interactive.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/companion_data_provider.dart';

class CompanionHomeScreen extends ConsumerWidget {
  const CompanionHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);
    final user = authState.value;
    final displayName = user?.displayName ?? 'Viajero';
    
    final companionNameAsync = ref.watch(companionNameProvider);
    final companionName = companionNameAsync.value ?? 'Echo';

    return Scaffold(
      backgroundColor: EsColors.backgroundDark,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hola, $displayName',
                            style: EsTypography.displayMedium.copyWith(color: EsColors.textPrimaryDark),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '¿Cómo te sientes hoy?',
                            style: EsTypography.bodyLarge.copyWith(color: EsColors.textSecondaryDark),
                          ),
                        ],
                      ),
                      EsInteractive(
                        onTap: () {
                          context.pushNamed(RouteNames.profile);
                        },
                        hoverScale: 1.05,
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: EsColors.surfaceElevated,
                          backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                          child: user?.avatarUrl == null
                              ? const Icon(Icons.person, color: EsColors.textSecondaryDark)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  
                  // Companion Status Card with Glassmorphism
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.8 + (0.2 * value),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1.5,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Subtle gradient background inside glass
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      EsColors.primaryBlue.withOpacity(0.2),
                                      EsColors.deepBlue.withOpacity(0.1),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: EsColors.primaryBlue.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: EsColors.primaryBlue.withOpacity(0.4),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(Icons.graphic_eq, color: Colors.white, size: 32),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            companionName,
                                            style: EsTypography.headlineLarge.copyWith(
                                              color: Colors.white,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black.withOpacity(0.3),
                                                  offset: const Offset(0, 2),
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            'Siempre aquí para escucharte',
                                            style: EsTypography.bodyMedium.copyWith(
                                              color: Colors.white.withOpacity(0.8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                EsButton(
                                  label: 'Iniciar Chat',
                                  onPressed: () => context.pushNamed(RouteNames.chat),
                                  variant: EsButtonVariant.primary,
                                  width: double.infinity,
                                  hasGlow: true,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Quick Actions
                  Text(
                    'Acciones Rápidas',
                    style: EsTypography.headlineMedium.copyWith(color: EsColors.textPrimaryDark),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.easeOutBack,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: Opacity(opacity: value, child: child),
                            );
                          },
                          child: _QuickActionCard(
                            icon: Icons.mood,
                            label: 'Estado de\nÁnimo',
                            color: EsColors.calm,
                            onTap: () => context.pushNamed(RouteNames.mood),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.easeOutBack,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: Opacity(opacity: value, child: child),
                            );
                          },
                          child: _QuickActionCard(
                            icon: Icons.phone_in_talk,
                            label: 'Llamada\nde Voz',
                            color: EsColors.success,
                            onTap: () => context.pushNamed(RouteNames.voiceCall),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  
                  // Temporary Logout Button for Testing
                  Center(
                    child: EsInteractive(
                      onTap: () async {
                        await ref.read(authControllerProvider.notifier).signOut();
                      },
                      hoverOpacity: 0.6,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.logout, color: EsColors.textSecondaryDark, size: 18),
                            const SizedBox(width: 8),
                            const Text(
                              'Cerrar sesión (Prueba)',
                              style: TextStyle(color: EsColors.textSecondaryDark),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: EsColors.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: EsColors.surfaceElevated),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: EsTypography.bodyMedium.copyWith(
                color: EsColors.textPrimaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
