import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/es_colors.dart';
import '../../../../core/constants/es_spacing.dart';
import '../../../../core/constants/es_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/design_system/atoms/es_button.dart';
import '../../../../shared/design_system/atoms/es_interactive.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EsColors.backgroundDark,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: EsColors.primaryBlue.withOpacity(0.15),
                boxShadow: [
                  BoxShadow(
                    color: EsColors.primaryBlue.withOpacity(0.15),
                    blurRadius: 100,
                    spreadRadius: 100,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: EsColors.neonCyan.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color: EsColors.neonCyan.withOpacity(0.1),
                    blurRadius: 100,
                    spreadRadius: 100,
                  ),
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.all(EsSpacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Logo / Icon
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              EsColors.primaryBlue.withOpacity(0.2),
                              EsColors.neonCyan.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: EsColors.primaryBlue.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Image.asset(
                          'assets/images/logo_icon.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: EsSpacing.xl),

                      // Title
                      Text(
                        'EchoSoul',
                        style: EsTypography.displaySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: EsSpacing.md),

                      // Subtitle
                      Text(
                        'Tu compañero de IA. Siempre aquí para escucharte, sin juzgar, 24/7.',
                        style: EsTypography.headlineSmall.copyWith(
                          color: EsColors.textSecondaryDark,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 64),

                      // Call to Action
                      EsInteractive(
                        hoverScale: 1.05,
                        child: EsButton(
                          label: 'Empezar mi viaje',
                          onPressed: () {
                            context.goNamed(RouteNames.login);
                          },
                        ),
                      ),
                      const SizedBox(height: EsSpacing.lg),

                      const SizedBox(height: EsSpacing.lg),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
