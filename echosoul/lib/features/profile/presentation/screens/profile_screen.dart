import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'package:universal_html/html.dart' as html;
import '../../../../core/constants/es_colors.dart';
import '../../../../core/constants/es_spacing.dart';
import '../../../../core/constants/es_typography.dart';
import '../../../../core/router/route_names.dart' as routes;
import '../../../billing/presentation/providers/billing_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_section_card.dart';
import '../widgets/profile_edit_sheet.dart';
import '../widgets/profile_language_sheet.dart';
import '../../../../shared/design_system/atoms/es_interactive.dart';
import '../../../../core/utils/es_platform.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';

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
              Text(S.of(context).errorLoadingProfile, style: EsTypography.bodyLarge),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.refresh(profileProvider),
                child: Text(S.of(context).retry, style: const TextStyle(color: EsColors.primaryBlue)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => ref.read(profileProvider.notifier).signOut(),
                child: Text(S.of(context).signOut, style: const TextStyle(color: EsColors.warning)),
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
                  title: Text(S.of(context).profileTitle, style: EsTypography.headlineMedium),
                ),
    
                // ── Contenido en lista ───────────────────────
                SliverPadding(
                  padding: const EdgeInsets.all(EsSpacing.md),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Sección: Tu información
                      ProfileSectionCard(
                        title: S.of(context).yourInformation,
                        children: [
                          _ProfileTile(
                            icon: Icons.person_outline,
                            label: S.of(context).nameLabel,
                            value: profile.displayName,
                            onTap: () => showProfileEditSheet(
                              context: context,
                              title: S.of(context).yourName,
                              hint: S.of(context).nameHint,
                              initialValue: profile.displayName,
                              onSave: (value) => ref
                                  .read(profileProvider.notifier)
                                  .updateField(profile.copyWith(displayName: value)),
                            ),
                          ),
                          _ProfileTile(
                            icon: Icons.email_outlined,
                            label: S.of(context).emailLabel,
                            value: profile.email,
                            isEditable: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: EsSpacing.md),
    
                      // Sección: Tu Companion
                      ProfileSectionCard(
                        title: S.of(context).yourCompanion,
                        children: [
                          _ProfileTile(
                            icon: Icons.graphic_eq,
                            label: S.of(context).companionNameLabel,
                            value: profile.companionName,
                            iconColor: EsColors.neonCyan,
                            onTap: () => showProfileEditSheet(
                              context: context,
                              title: S.of(context).companionNameLabel,
                              hint: S.of(context).companionNameHint,
                              initialValue: profile.companionName,
                              onSave: (value) => ref
                                  .read(profileProvider.notifier)
                                  .updateField(profile.copyWith(companionName: value)),
                            ),
                          ),
                          SwitchListTile(
                            title: Text(S.of(context).pauseCompanion, style: const TextStyle(color: EsColors.textPrimaryDark, fontSize: 15)),
                            subtitle: Text(S.of(context).pauseCompanionSubtitle, style: const TextStyle(color: EsColors.textSecondaryDark, fontSize: 12)),
                            secondary: const Icon(Icons.snooze_outlined, color: EsColors.warning, size: 22),
                            value: profile.isPaused,
                            activeColor: EsColors.warning,
                            inactiveTrackColor: EsColors.surfaceDark,
                            onChanged: (bool value) {
                              ref.read(profileProvider.notifier).updateField(
                                    profile.copyWith(isPaused: value),
                                  );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: EsSpacing.md),
    
                      // Sección: Idioma
                      ProfileSectionCard(
                        title: S.of(context).languageSectionTitle,
                        children: [
                          _ProfileTile(
                            icon: Icons.language,
                            label: S.of(context).appLanguageLabel,
                            value: Localizations.localeOf(context).languageCode == 'en' ? '🇬🇧 English' : '🇪🇸 Español',
                            iconColor: EsColors.calm,
                            onTap: () => showLanguageSheet(context: context),
                          ),
                        ],
                      ),
                      const SizedBox(height: EsSpacing.md),
    
                      // Sección: Contacto de emergencia
                      ProfileSectionCard(
                        title: S.of(context).emergencyContactSection,
                        subtitle: S.of(context).emergencyContactSubtitle,
                        children: [
                          _ProfileTile(
                            icon: Icons.person_pin_outlined,
                            label: S.of(context).contactNameLabel,
                            value: profile.crisisContactName?.isNotEmpty == true
                                ? profile.crisisContactName!
                                : S.of(context).notConfigured,
                            valueColor: profile.crisisContactName?.isNotEmpty == true
                                ? null
                                : EsColors.textSecondaryDark,
                            iconColor: EsColors.distress,
                            onTap: () => showProfileEditSheet(
                              context: context,
                              title: S.of(context).contactNameLabel,
                              hint: S.of(context).contactNameHint,
                              initialValue: profile.crisisContactName ?? '',
                              onSave: (value) => ref
                                  .read(profileProvider.notifier)
                                  .updateField(profile.copyWith(crisisContactName: value)),
                            ),
                          ),
                          _ProfileTile(
                            icon: Icons.phone_outlined,
                            label: S.of(context).phoneLabel,
                            value: profile.crisisContactPhone?.isNotEmpty == true
                                ? profile.crisisContactPhone!
                                : S.of(context).notConfigured,
                            valueColor: profile.crisisContactPhone?.isNotEmpty == true
                                ? null
                                : EsColors.textSecondaryDark,
                            iconColor: EsColors.distress,
                            keyboardType: TextInputType.phone,
                            onTap: () => showProfileEditSheet(
                              context: context,
                              title: S.of(context).emergencyPhoneTitle,
                              hint: S.of(context).phoneHint,
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
                        title: S.of(context).legalInfoSection,
                        children: [
                          _ProfileTile(
                            icon: Icons.gavel_outlined,
                            label: S.of(context).legalNoticesLabel,
                            value: S.of(context).legalNoticesSubtitle,
                            iconColor: EsColors.primaryBlue,
                            onTap: () => context.goNamed(routes.RouteNames.legal),
                          ),
                        ],
                      ),
                      const SizedBox(height: EsSpacing.md),

                      // Sección: Plan Premium
                      Consumer(
                        builder: (context, ref, _) {
                          final billingAsync = ref.watch(billingProvider);
                          return billingAsync.when(
                            loading: () => ProfileSectionCard(
                              title: S.of(context).planSection,
                              children: [
                                _ProfileTile(
                                  icon: Icons.workspace_premium,
                                  label: S.of(context).planStatusLabel,
                                  value: S.of(context).loading,
                                  iconColor: EsColors.primaryBlue,
                                  isEditable: false,
                                ),
                              ],
                            ),
                            error: (_, __) => const SizedBox.shrink(),
                            data: (billing) => ProfileSectionCard(
                              title: S.of(context).planSection,
                              children: [
                                _ProfileTile(
                                  icon: Icons.workspace_premium,
                                  label: S.of(context).planStatusLabel,
                                  value: billing.isPremium ? S.of(context).premium : S.of(context).free,
                                  iconColor: billing.isPremium
                                      ? EsColors.warning
                                      : EsColors.primaryBlue,
                                  isEditable: false,
                                ),
                                if (billing.isFree) ...[
                                  _ProfileTile(
                                    icon: Icons.forum_outlined,
                                    label: S.of(context).messagesToday,
                                    value: '${billing.messagesUsed} / ${billing.dailyLimit}',
                                    iconColor: billing.remainingMessages <= 5
                                        ? EsColors.warning
                                        : EsColors.calm,
                                    isEditable: false,
                                  ),
                                  _ProfileTile(
                                    icon: Icons.arrow_circle_up_outlined,
                                    label: '',
                                    value: S.of(context).upgradeToPremium,
                                    iconColor: EsColors.primaryBlue,
                                    valueColor: EsColors.primaryBlue,
                                    onTap: () => context.push(routes.RouteNames.paywall),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: EsSpacing.md),
                      ProfileSectionCard(
                        title: S.of(context).accountSection,
                        children: [
                          _ProfileTile(
                            icon: Icons.logout,
                            label: S.of(context).signOut,
                            value: '',
                            isEditable: false,
                            iconColor: EsColors.warning,
                            onTap: () => _confirmSignOut(context, ref),
                          ),
                          _ProfileTile(
                            icon: Icons.download_outlined,
                            label: S.of(context).exportDataLabel,
                            value: '',
                            isEditable: false,
                            iconColor: EsColors.primaryBlue,
                            onTap: () => _handleExportData(context, ref),
                          ),
                          _ProfileTile(
                            icon: Icons.delete_forever_outlined,
                            label: S.of(context).deleteAccountLabel,
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
        title: Text(S.of(context).signOut, style: EsTypography.headlineMedium),
        content: Text(
          S.of(context).signOutConfirmMessage,
          style: EsTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context).cancel, style: const TextStyle(color: EsColors.textSecondaryDark)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(profileProvider.notifier).signOut();
            },
            child: Text(S.of(context).exitSignOut, style: const TextStyle(color: EsColors.warning)),
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
        title: Text(S.of(context).deleteAccountLabel, style: EsTypography.headlineMedium),
        content: Text(
          S.of(context).deleteAccountConfirmMessage,
          style: EsTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context).cancel, style: const TextStyle(color: EsColors.textSecondaryDark)),
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
                      content: Text(S.of(context).errorDeletingAccount(e.toString())),
                      backgroundColor: EsColors.distress,
                    ),
                  );
                }
              }
            },
            child: Text(S.of(context).deleteBtn, style: const TextStyle(color: EsColors.distress)),
          ),
        ],
      ),
    );
  }

  void _handleExportData(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Card(
          color: EsColors.surfaceDark,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: EsColors.primaryBlue),
                const SizedBox(height: 16),
                Text(
                  S.of(context).preparingDataFile,
                  style: const TextStyle(color: EsColors.textPrimaryDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final jsonData = await ref.read(profileProvider.notifier).exportUserData();
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // Cierra el loading dialog

      if (EsPlatform.isWeb) {
        // En Web, creamos un archivo virtual y lo descargamos
        final bytes = utf8.encode(jsonData);
        final blob = html.Blob([bytes], 'application/json');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..style.display = 'none'
          ..download = 'echosoul_mis_datos.json';
        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).downloadStarted),
            backgroundColor: EsColors.success,
          ),
        );
      } else {
        // En móviles, guardamos el archivo temporalmente y lo compartimos
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/echosoul_mis_datos.json');
        await file.writeAsString(jsonData);

        final xFile = XFile(file.path, mimeType: 'application/json');
        await Share.shareXFiles([xFile], subject: S.of(context).exportedDataSubject);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Asegura cerrar el loading en caso de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).errorExportingData(e.toString())),
            backgroundColor: EsColors.distress,
          ),
        );
      }
    }
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
          SnackBar(
            content: Text(S.of(context).photoUpdatedSuccessfully),
            backgroundColor: EsColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).errorUploadingPhoto(e.toString())),
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
