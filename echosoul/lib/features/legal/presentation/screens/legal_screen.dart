import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/es_colors.dart';
import '../../../../core/constants/es_spacing.dart';
import '../../../../core/constants/es_typography.dart';
import '../../../../core/router/route_names.dart';
import 'package:echosoul/features/profile/presentation/widgets/profile_section_card.dart';
import '../../../../l10n/app_localizations.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('--- [LEGAL SCREEN] BUILD ---');
    debugPrint('canPop: ${context.canPop()}');
    return Scaffold(
      backgroundColor: EsColors.backgroundDark,
      appBar: AppBar(
        title: Text(S.of(context).legalNoticesLabel, style: EsTypography.headlineMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: EsColors.textPrimaryDark),
          onPressed: () {
            debugPrint('--- [LEGAL SCREEN] BACK BUTTON PRESSED ---');
            debugPrint('canPop: ${context.canPop()}');
            if (context.canPop()) {
              context.pop();
            } else {
              debugPrint('LEGAL: canPop is FALSE -> navigating to home');
              final user = Supabase.instance.client.auth.currentUser;
              if (user != null) {
                context.goNamed(RouteNames.companionHome);
              } else {
                context.goNamed(RouteNames.login);
              }
            }
          },
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(EsSpacing.md),
            child: Column(
              children: [
                // ── Ética de la IA ────────────────────────────────
                ProfileSectionCard(
                  title: S.of(context).legalEthicalCommitment,
                  subtitle: S.of(context).legalHowWeUseAI,
                  children: [
                    _LegalTile(
                      title: S.of(context).legalCompanionNotTherapy,
                      description: S.of(context).legalCompanionNotTherapyDesc,
                    ),
                    _LegalTile(
                      title: S.of(context).legalTransparency,
                      description: S.of(context).legalTransparencyDesc,
                    ),
                    _LegalTile(
                      title: S.of(context).legalPreventDependency,
                      description: S.of(context).legalPreventDependencyDesc,
                    ),
                  ],
                ),
                const SizedBox(height: EsSpacing.md),

                // ── Documentos Legales ────────────────────────────
                ProfileSectionCard(
                  title: S.of(context).legalOfficialDocs,
                  children: [
                    _LegalActionTile(
                      icon: Icons.description_outlined,
                      label: S.of(context).legalTermsConditions,
                      onTap: () => _launchLegalUrl(context, 'terms'),
                    ),
                    _LegalActionTile(
                      icon: Icons.privacy_tip_outlined,
                      label: S.of(context).legalPrivacyPolicy,
                      onTap: () => _launchLegalUrl(context, 'privacy'),
                    ),
                    _LegalActionTile(
                      icon: Icons.cookie_outlined,
                      label: S.of(context).legalCookiePolicy,
                      onTap: () => _launchLegalUrl(context, 'cookies'),
                    ),
                  ],
                ),
                const SizedBox(height: EsSpacing.md),

                // ── Seguridad ─────────────────────────────────────
                ProfileSectionCard(
                  title: S.of(context).legalInCaseOfCrisis,
                  children: [
                    _LegalTile(
                      title: S.of(context).legalImmediateHelp,
                      description: S.of(context).legalImmediateHelpDesc,
                    ),
                    _LegalActionTile(
                      icon: Icons.emergency_outlined,
                      label: S.of(context).legalCallEmergencies,
                      onTap: () => _launchUrl('tel:112'),
                    ),
                    _LegalActionTile(
                      icon: Icons.healing_outlined,
                      label: S.of(context).legalSuicidePrevention,
                      onTap: () => _launchUrl('tel:024'),
                    ),
                    _LegalActionTile(
                      icon: Icons.favorite_outline,
                      label: S.of(context).legalHopeLine,
                      onTap: () => _launchUrl('tel:717003717'),
                    ),
                  ],
                ),
                const SizedBox(height: EsSpacing.xxl),

                Text(
                  'EchoSoul v1.0.0 — May 2026',
                  style: EsTypography.caption.copyWith(color: EsColors.textSecondaryDark),
                ),
                const SizedBox(height: EsSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _launchLegalUrl(BuildContext context, String page) {
    final locale = Localizations.localeOf(context);
    final suffix = locale.languageCode == 'es' ? '' : '-${locale.languageCode}';
    _launchUrl('https://echosoul.dev/$page$suffix');
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }
}

class _LegalTile extends StatelessWidget {
  final String title;
  final String description;

  const _LegalTile({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: EsSpacing.md, vertical: EsSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: EsTypography.labelLarge.copyWith(color: EsColors.neonCyan)),
          const SizedBox(height: 4),
          Text(description, style: EsTypography.bodyMedium),
          const SizedBox(height: 4),
          const Divider(color: EsColors.divider),
        ],
      ),
    );
  }
}

class _LegalActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _LegalActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: EsColors.primaryBlue),
      title: Text(label, style: EsTypography.bodyLarge),
      trailing: const Icon(Icons.open_in_new, size: 18, color: EsColors.textSecondaryDark),
      onTap: onTap,
    );
  }
}
