import 'package:flutter/material.dart';
import '../../../../core/constants/es_colors.dart';
import '../../../../core/constants/es_spacing.dart';
import '../../../../core/constants/es_typography.dart';

/// Tarjeta de sección con título y lista de tiles hijos.
class ProfileSectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;

  const ProfileSectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: EsSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: EsTypography.caption.copyWith(
                  letterSpacing: 1.2,
                  color: EsColors.textSecondaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: EsTypography.caption),
              ],
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: EsColors.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: EsColors.surfaceElevated, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: EsColors.surfaceElevated,
                      indent: EsSpacing.md + 22 + EsSpacing.md,
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
