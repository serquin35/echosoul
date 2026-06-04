import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/es_colors.dart';
import '../../../../core/constants/es_spacing.dart';
import '../../../../core/constants/es_typography.dart';
import '../../../../core/utils/es_platform.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/billing_provider.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isYearly = false;

  @override
  Widget build(BuildContext context) {
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
        data: (billing) => LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Padding(
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
                    S.of(context).paywallTitle,
                    style: EsTypography.headlineLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    S.of(context).paywallSubtitle,
                    style: EsTypography.bodyMedium.copyWith(
                      color: EsColors.textSecondaryDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Tarjeta de precios
                  Container(
                    padding: const EdgeInsets.all(EsSpacing.lg),
                    decoration: BoxDecoration(
                      color: EsColors.surfaceDark.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Toggle Mensual / Anual
                        _PlanToggle(
                          isYearly: _isYearly,
                          onChanged: (val) => setState(() => _isYearly = val),
                        ),
                        const SizedBox(height: 24),
                        // Precio según selección
                        Center(
                          child: Column(
                            children: [
                              Text(
                                _isYearly ? '€39.99' : '€4.99',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                              Text(
                                _isYearly ? '/año' : '/mes',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: EsColors.textSecondaryDark,
                                ),
                              ),
                              if (_isYearly) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: EsColors.neonCyan.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'AHORRA ~€20',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: EsColors.neonCyan,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Text(
                                S.of(context).paywallCancelSubtitle,
                                style: EsTypography.caption.copyWith(
                                  color: EsColors.textSecondaryDark,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Divider(color: Colors.white.withOpacity(0.08), height: 1),
                        const SizedBox(height: 24),
                        // Beneficios — VOZ primero
                        _FeatureRow(
                          icon: Icons.mic_outlined,
                          title: S.of(context).paywallVoiceCalls,
                          subtitle: S.of(context).paywallVoiceCallsSub,
                        ),
                        const SizedBox(height: 16),
                        _FeatureRow(
                          icon: Icons.forum_outlined,
                          title: S.of(context).paywallLimitlessMessages,
                          subtitle: S.of(context).paywallLimitlessMessagesSub,
                        ),
                        const SizedBox(height: 16),
                        _FeatureRow(
                          icon: Icons.psychology_outlined,
                          title: S.of(context).paywallLongTermMemory,
                          subtitle: S.of(context).paywallLongTermMemorySub,
                        ),
                        const SizedBox(height: 16),
                        _FeatureRow(
                          icon: Icons.auto_awesome_outlined,
                          title: S.of(context).paywallProactiveInteractions,
                          subtitle: S.of(context).paywallProactiveInteractionsSub,
                        ),
                        const SizedBox(height: 32),
                        // Acciones según plataforma
                        if (!billing.isPremium) ...[
                          if (EsPlatform.isWeb) ...[
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
                                child: Text(
                                  _isYearly
                                      ? 'Suscripción Anual — €39.99'
                                      : S.of(context).paywallStartSubscription,
                                  style: const TextStyle(
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
                                color: EsColors.backgroundDark.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: EsColors.primaryBlue.withOpacity(0.3)),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.info_outline, color: EsColors.neonCyan, size: 28),
                                  const SizedBox(height: 12),
                                  Text(
                                    S.of(context).paywallWebSubscriptionTitle,
                                    style: EsTypography.bodyLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    S.of(context).paywallWebSubscriptionDesc,
                                    style: EsTypography.bodyMedium.copyWith(
                                      color: EsColors.textSecondaryDark,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(EsSpacing.md),
                            decoration: BoxDecoration(
                              color: EsColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: EsColors.success.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle, color: EsColors.success),
                                const SizedBox(width: 8),
                                Text(
                                  S.of(context).paywallAlreadyPremium,
                                  style: const TextStyle(
                                    color: EsColors.success,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openCheckout(BuildContext context) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    // Lemon Squeezy product checkout UUID (includes both monthly & yearly variants)
    const productUuid = '8ea74eeb-8f3b-416a-85ae-5e31561aacf8';
    const storeSlug = 'echosoul';

    final checkoutUrl =
        'https://$storeSlug.lemonsqueezy.com/checkout/buy/$productUuid'
        '?checkout[custom][user_id]=${Uri.encodeComponent(userId)}'
        '&checkout[media]=0';
    final uri = Uri.parse(checkoutUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _PlanToggle extends StatelessWidget {
  final bool isYearly;
  final ValueChanged<bool> onChanged;

  const _PlanToggle({required this.isYearly, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: EsColors.backgroundDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isYearly ? EsColors.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Mensual',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isYearly ? EsColors.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Anual',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: EsColors.neonCyan.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '-33%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: EsColors.neonCyan,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
