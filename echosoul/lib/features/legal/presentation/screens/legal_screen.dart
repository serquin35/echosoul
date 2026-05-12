import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/es_colors.dart';
import '../../../../core/constants/es_spacing.dart';
import '../../../../core/constants/es_typography.dart';
import '../../../../core/router/route_names.dart';
import 'package:echosoul/features/profile/presentation/widgets/profile_section_card.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EsColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Avisos Legales y Ética', style: EsTypography.headlineMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: EsColors.textPrimaryDark),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(RouteNames.companionHome);
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
                  title: 'Nuestro Compromiso Ético',
                  subtitle: 'Cómo usamos la Inteligencia Artificial',
                  children: [
                    _LegalTile(
                      title: 'Acompañamiento, no Terapia',
                      description: 'EchoSoul es un acompañante virtual diseñado para reducir la soledad. No sustituye el diagnóstico o tratamiento de un profesional de la salud mental.',
                    ),
                    _LegalTile(
                      title: 'Transparencia',
                      description: 'Todas tus interacciones son generadas por modelos de IA. No estás hablando con un humano real.',
                    ),
                    _LegalTile(
                      title: 'Prevención de Dependencia',
                      description: 'Fomentamos el uso responsable. EchoSoul te recordará la importancia de tus conexiones humanas reales.',
                    ),
                  ],
                ),
                const SizedBox(height: EsSpacing.md),

                // ── Documentos Legales ────────────────────────────
                ProfileSectionCard(
                  title: 'Documentación Oficial',
                  children: [
                    _LegalActionTile(
                      icon: Icons.description_outlined,
                      label: 'Términos y Condiciones',
                      onTap: () => _launchUrl('https://echosoul.app/terms'),
                    ),
                    _LegalActionTile(
                      icon: Icons.privacy_tip_outlined,
                      label: 'Política de Privacidad',
                      onTap: () => _launchUrl('https://echosoul.app/privacy'),
                    ),
                    _LegalActionTile(
                      icon: Icons.cookie_outlined,
                      label: 'Política de Cookies',
                      onTap: () => _launchUrl('https://echosoul.app/cookies'),
                    ),
                  ],
                ),
                const SizedBox(height: EsSpacing.md),

                // ── Seguridad ─────────────────────────────────────
                ProfileSectionCard(
                  title: 'En caso de crisis',
                  children: [
                    _LegalTile(
                      title: 'Ayuda Inmediata',
                      description: 'Si sientes que estás en peligro o tienes pensamientos de hacerte daño, por favor contacta inmediatamente con los servicios de emergencia de tu país (ej: 112 en España, 911 en EEUU).',
                    ),
                    _LegalActionTile(
                      icon: Icons.phone_in_talk,
                      label: 'Llamar a Emergencias (112)',
                      onTap: () => _launchUrl('tel:112'),
                    ),
                  ],
                ),
                const SizedBox(height: EsSpacing.xxl),

                Text(
                  'EchoSoul v1.0.0 — Mayo 2026',
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
