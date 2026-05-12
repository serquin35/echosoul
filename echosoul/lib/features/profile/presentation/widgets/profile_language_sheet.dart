import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/es_colors.dart';
import '../../../../core/constants/es_spacing.dart';
import '../../../../core/constants/es_typography.dart';

const _kLangKey = 'preferred_language';

Future<void> showLanguageSheet({required BuildContext context}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => const _LanguageSheet(),
  );
}

class _LanguageSheet extends StatefulWidget {
  const _LanguageSheet();

  @override
  State<_LanguageSheet> createState() => _LanguageSheetState();
}

class _LanguageSheetState extends State<_LanguageSheet> {
  String _selected = 'es';

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _selected = prefs.getString(_kLangKey) ?? 'es');
  }

  Future<void> _select(String code) async {
    if (code != 'es') return; // Solo ES activo por ahora
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLangKey, code);
    setState(() => _selected = code);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(EsSpacing.md),
      decoration: BoxDecoration(
        color: EsColors.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: EsColors.surfaceElevated),
      ),
      child: Padding(
        padding: const EdgeInsets.all(EsSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: EsColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: EsSpacing.lg),
            const Text('Idioma de la app', style: EsTypography.headlineMedium),
            const SizedBox(height: EsSpacing.md),

            // Español — activo
            _LanguageTile(
              flag: '🇪🇸',
              name: 'Español',
              code: 'es',
              isSelected: _selected == 'es',
              isEnabled: true,
              onTap: () => _select('es'),
            ),
            const SizedBox(height: EsSpacing.sm),

            // English — próximamente
            _LanguageTile(
              flag: '🇬🇧',
              name: 'English',
              code: 'en',
              isSelected: false,
              isEnabled: false,
              badge: 'Próximamente',
              onTap: () {},
            ),
            const SizedBox(height: EsSpacing.sm),

            // Português — próximamente
            _LanguageTile(
              flag: '🇧🇷',
              name: 'Português',
              code: 'pt',
              isSelected: false,
              isEnabled: false,
              badge: 'Próximamente',
              onTap: () {},
            ),
            const SizedBox(height: EsSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String flag;
  final String name;
  final String code;
  final bool isSelected;
  final bool isEnabled;
  final String? badge;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.flag,
    required this.name,
    required this.code,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.45,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: EsSpacing.md,
            vertical: EsSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? EsColors.primaryBlue.withOpacity(0.15)
                : EsColors.backgroundDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? EsColors.primaryBlue : EsColors.surfaceElevated,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: EsSpacing.md),
              Expanded(
                child: Text(
                  name,
                  style: EsTypography.bodyLarge.copyWith(
                    color: isEnabled
                        ? EsColors.textPrimaryDark
                        : EsColors.textSecondaryDark,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: EsSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: EsColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge!,
                    style: EsTypography.caption.copyWith(fontSize: 11),
                  ),
                ),
              if (isSelected)
                const Padding(
                  padding: EdgeInsets.only(left: EsSpacing.sm),
                  child: Icon(Icons.check_circle, color: EsColors.primaryBlue, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
