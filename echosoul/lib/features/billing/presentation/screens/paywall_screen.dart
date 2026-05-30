import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/es_colors.dart';
import '../../../../core/constants/es_spacing.dart';
import '../../../../core/constants/es_typography.dart';
import '../providers/billing_provider.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billingAsync = ref.watch(billingProvider);

    return Scaffold(
      backgroundColor: EsColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: EsColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: billingAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: EsColors.primaryBlue),
        ),
        error: (e, _) => Center(
          child: Text('Error: $e', style: const TextStyle(color: EsColors.distress)),
        ),
        data: (billing) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(EsSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [EsColors.primaryBlue, EsColors.neonCyan],
                      ),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: EsColors.neonCyan.withOpacity(0.4),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: const Text(
                      'ECHOSOUL PREMIUM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Libera a tu Companion',
                    style: EsTypography.headlineLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Conversa sin barreras con el asistente de IA empática que te comprende.',
                    style: EsTypography.bodyMedium.copyWith(
                      color: EsColors.textSecondaryDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(EsSpacing.lg),
                    decoration: BoxDecoration(
                      color: EsColors.surfaceDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: EsColors.divider),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '\$9.99',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        const Text(
                          '/mes',
                          style: TextStyle(
                            fontSize: 16,
                            color: EsColors.textSecondaryDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cancela en cualquier momento desde tu perfil.',
                          style: EsTypography.caption.copyWith(
                            color: EsColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _FeatureRow(
                    icon: Icons.forum_outlined,
                    title: 'Mensajes Diarios Ilimitados',
                    subtitle: 'Sin restricción de límite diario',
                  ),
                  const SizedBox(height: 16),
                  _FeatureRow(
                    icon: Icons.psychology_outlined,
                    title: 'Memoria a Largo Plazo',
                    subtitle: 'Tu Companion recordará cada conversación',
                  ),
                  const SizedBox(height: 16),
                  _FeatureRow(
                    icon: Icons.auto_awesome_outlined,
                    title: 'Interacciones Proactivas',
                    subtitle: 'Buenos días, insights semanales y más',
                  ),
                  const SizedBox(height: 16),
                  _FeatureRow(
                    icon: Icons.mic_outlined,
                    title: 'Llamadas de Voz (Próximamente)',
                    subtitle: 'Acceso anticipado cuando esté disponible',
                  ),
                  const SizedBox(height: 32),
                  if (!billing.isPremium) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _openCheckout(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: EsColors.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 8,
                          shadowColor: EsColors.primaryBlue.withOpacity(0.5),
                        ),
                        child: const Text(
                          'Iniciar Suscripción',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(EsSpacing.md),
                      decoration: BoxDecoration(
                        color: EsColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: EsColors.success.withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: EsColors.success),
                          SizedBox(width: 8),
                          Text(
                            '¡Ya eres Premium!',
                            style: TextStyle(
                              color: EsColors.success,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openCheckout(BuildContext context) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final url = 'https://echosoul.one/upgrade?user_id=$userId';
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: EsColors.neonCyan.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: EsColors.neonCyan, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: EsTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: EsTypography.caption.copyWith(
                  color: EsColors.textSecondaryDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
