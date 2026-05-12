import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/es_colors.dart';
import '../../../../core/constants/es_spacing.dart';
import '../../../../core/constants/es_typography.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_section_card.dart';
import '../widgets/profile_edit_sheet.dart';
import '../widgets/profile_language_sheet.dart';
import '../../../../shared/design_system/atoms/es_interactive.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: EsColors.backgroundDark,
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: EsColors.primaryBlue),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: EsColors.distress, size: 48),
              const SizedBox(height: 16),
              Text('Error al cargar perfil', style: EsTypography.bodyLarge),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.refresh(profileProvider),
                child: const Text('Reintentar', style: TextStyle(color: EsColors.primaryBlue)),
              ),
            ],
          ),
        ),
        data: (profile) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: CustomScrollView(
              slivers: [
                // ── AppBar con avatar ────────────────────────
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  backgroundColor: EsColors.backgroundDark,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _AvatarHeader(
                      displayName: profile.displayName,
                      avatarUrl: profile.avatarUrl,
                      email: profile.email,
                    ),
                  ),
                  title: const Text('Mi Perfil', style: EsTypography.headlineMedium),
                ),
    
                // ── Contenido en lista ───────────────────────
                SliverPadding(
                  padding: const EdgeInsets.all(EsSpacing.md),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Sección: Tu información
                      ProfileSectionCard(
                        title: 'Tu información',
                        children: [
                          _ProfileTile(
                            icon: Icons.person_outline,
                            label: 'Nombre',
                            value: profile.displayName,
                            onTap: () => showProfileEditSheet(
                              context: context,
                              title: 'Tu nombre',
                              hint: 'Como quieres que te llamemos',
                              initialValue: profile.displayName,
                              onSave: (value) => ref
                                  .read(profileProvider.notifier)
                                  .updateField(profile.copyWith(displayName: value)),
                            ),
                          ),
                          _ProfileTile(
                            icon: Icons.email_outlined,
                            label: 'Correo',
                            value: profile.email,
                            isEditable: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: EsSpacing.md),
    
                      // Sección: Tu Companion
                      ProfileSectionCard(
                        title: 'Tu Companion',
                        children: [
                          _ProfileTile(
                            icon: Icons.graphic_eq,
                            label: 'Nombre del Companion',
                            value: profile.companionName,
                            iconColor: EsColors.neonCyan,
                            onTap: () => showProfileEditSheet(
                              context: context,
                              title: 'Nombre del Companion',
                              hint: 'Ej: Echo, Luna, Kai…',
                              initialValue: profile.companionName,
                              onSave: (value) => ref
                                  .read(profileProvider.notifier)
                                  .updateField(profile.copyWith(companionName: value)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: EsSpacing.md),
    
                      // Sección: Idioma
                      ProfileSectionCard(
                        title: 'Idioma',
                        children: [
                          _ProfileTile(
                            icon: Icons.language,
                            label: 'Idioma de la app',
                            value: '🇪🇸 Español',
                            iconColor: EsColors.calm,
                            onTap: () => showLanguageSheet(context: context),
                          ),
                        ],
                      ),
                      const SizedBox(height: EsSpacing.md),
    
                      // Sección: Contacto de emergencia
                      ProfileSectionCard(
                        title: 'Contacto de emergencia',
                        subtitle: 'EchoSoul te lo recordará si lo necesitas',
                        children: [
                          _ProfileTile(
                            icon: Icons.person_pin_outlined,
                            label: 'Nombre del contacto',
                            value: profile.crisisContactName?.isNotEmpty == true
                                ? profile.crisisContactName!
                                : 'No configurado',
                            valueColor: profile.crisisContactName?.isNotEmpty == true
                                ? null
                                : EsColors.textSecondaryDark,
                            iconColor: EsColors.distress,
                            onTap: () => showProfileEditSheet(
                              context: context,
                              title: 'Nombre del contacto',
                              hint: 'Nombre de alguien de confianza',
                              initialValue: profile.crisisContactName ?? '',
                              onSave: (value) => ref
                                  .read(profileProvider.notifier)
                                  .updateField(profile.copyWith(crisisContactName: value)),
                            ),
                          ),
                          _ProfileTile(
                            icon: Icons.phone_outlined,
                            label: 'Teléfono',
                            value: profile.crisisContactPhone?.isNotEmpty == true
                                ? profile.crisisContactPhone!
                                : 'No configurado',
                            valueColor: profile.crisisContactPhone?.isNotEmpty == true
                                ? null
                                : EsColors.textSecondaryDark,
                            iconColor: EsColors.distress,
                            keyboardType: TextInputType.phone,
                            onTap: () => showProfileEditSheet(
                              context: context,
                              title: 'Teléfono de emergencia',
                              hint: '+34 600 000 000',
                              initialValue: profile.crisisContactPhone ?? '',
                              keyboardType: TextInputType.phone,
                              onSave: (value) => ref
                                  .read(profileProvider.notifier)
                                  .updateField(profile.copyWith(crisisContactPhone: value)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: EsSpacing.md),
    
                      const SizedBox(height: EsSpacing.md),
    
                      // Sección: Legal
                      ProfileSectionCard(
                        title: 'Información Legal',
                        children: [
                          _ProfileTile(
                            icon: Icons.gavel_outlined,
                            label: 'Avisos Legales y Ética',
                            value: 'Términos, Privacidad y Compromiso IA',
                            iconColor: EsColors.primaryBlue,
                            onTap: () => context.push(RouteNames.legal),
                          ),
                        ],
                      ),
                      const SizedBox(height: EsSpacing.md),
                      ProfileSectionCard(
                        title: 'Cuenta',
                        children: [
                          _ProfileTile(
                            icon: Icons.logout,
                            label: 'Cerrar sesión',
                            value: '',
                            isEditable: false,
                            iconColor: EsColors.warning,
                            onTap: () => _confirmSignOut(context, ref),
                          ),
                          _ProfileTile(
                            icon: Icons.delete_forever_outlined,
                            label: 'Eliminar cuenta',
                            value: '',
                            isEditable: false,
                            labelColor: EsColors.distress,
                            iconColor: EsColors.distress,
                            onTap: () => _confirmDeleteAccount(context, ref),
                          ),
                        ],
                      ),
                      const SizedBox(height: EsSpacing.md),
    
                      // Versión
                      Center(
                        child: Text(
                          'EchoSoul v1.0.0',
                          style: EsTypography.caption.copyWith(color: EsColors.textSecondaryDark),
                        ),
                      ),
                      const SizedBox(height: EsSpacing.xl),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: EsColors.surfaceDark,
        title: const Text('Cerrar sesión', style: EsTypography.headlineMedium),
        content: const Text(
          '¿Seguro que quieres cerrar sesión?',
          style: EsTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: EsColors.textSecondaryDark)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(profileProvider.notifier).signOut();
            },
            child: const Text('Salir', style: TextStyle(color: EsColors.warning)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: EsColors.surfaceDark,
        title: const Text('Eliminar cuenta', style: EsTypography.headlineMedium),
        content: const Text(
          'Esta acción es irreversible. Todos tus datos serán eliminados permanentemente.',
          style: EsTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: EsColors.textSecondaryDark)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(profileProvider.notifier).deleteAccount();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar cuenta: $e'),
                      backgroundColor: EsColors.distress,
                    ),
                  );
                }
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: EsColors.distress)),
          ),
        ],
      ),
    );
  }
}

// ── Avatar Header ────────────────────────────────────────
class _AvatarHeader extends ConsumerWidget {
  final String displayName;
  final String? avatarUrl;
  final String email;

  const _AvatarHeader({
    required this.displayName,
    required this.avatarUrl,
    required this.email,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [EsColors.backgroundDark, EsColors.surfaceDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 48),
            EsInteractive(
              onTap: () => _pickAvatar(context, ref),
              hoverScale: 1.05,
              child: Stack(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: avatarUrl == null
                          ? const LinearGradient(
                              colors: [EsColors.primaryBlue, EsColors.neonCyan],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      border: Border.all(color: EsColors.primaryBlue, width: 2),
                    ),
                    child: ClipOval(
                      child: avatarUrl != null
                          ? Image.network(avatarUrl!, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _initials(displayName))
                          : _initials(displayName),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: EsColors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(displayName, style: EsTypography.headlineLarge),
            const SizedBox(height: 4),
            Text(email, style: EsTypography.caption),
          ],
        ),
      ),
    );
  }

  Widget _initials(String name) {
    final parts = name.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : name.isNotEmpty
            ? name[0].toUpperCase()
            : '?';
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _pickAvatar(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null) return;

    try {
      await ref.read(profileProvider.notifier).uploadAvatar(File(picked.path));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto actualizada correctamente.'),
            backgroundColor: EsColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir la foto: $e'),
            backgroundColor: EsColors.distress,
          ),
        );
      }
    }
  }
}

// ── Profile Tile ─────────────────────────────────────────
class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final Color? valueColor;
  final Color? labelColor;
  final bool isEditable;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.valueColor,
    this.labelColor,
    this.isEditable = true,
    this.keyboardType,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      mouseCursor: SystemMouseCursors.click,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: EsSpacing.md,
          vertical: EsSpacing.sm + 2,
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? EsColors.primaryBlue, size: 22),
            const SizedBox(width: EsSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: EsTypography.caption.copyWith(
                      color: labelColor ?? EsColors.textSecondaryDark,
                    ),
                  ),
                  if (value.isNotEmpty)
                    Text(
                      value,
                      style: EsTypography.bodyLarge.copyWith(
                        color: valueColor ?? EsColors.textPrimaryDark,
                        fontSize: 15,
                      ),
                    ),
                ],
              ),
            ),
            if (isEditable)
              const Icon(Icons.chevron_right, color: EsColors.textSecondaryDark, size: 20),
          ],
        ),
      ),
    );
  }
}
