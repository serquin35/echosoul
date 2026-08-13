import 'dart:math' show min;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/es_colors.dart';
import '../../../../core/constants/es_spacing.dart';
import '../../../../core/constants/es_typography.dart';
import '../../../../core/utils/es_platform.dart';
import '../../../../core/router/route_names.dart';
import '../../../billing/presentation/providers/billing_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/companion_data_provider.dart';
import '../widgets/chat_message_bubble.dart';
import '../../../../l10n/app_localizations.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companionName = ref.watch(companionNameProvider).value ?? 'Echo';
    final useSidebar = EsPlatform.useSidebarNavigation ||
        MediaQuery.sizeOf(context).width >= EsPlatform.sidebarBreakpoint;

    return Scaffold(
      backgroundColor: EsColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _ChatHeader(companionName: companionName, showBack: !useSidebar),
            if (ref.watch(chatProvider).isCrisis) const _CrisisBanner(),
            const Expanded(child: _MessageList()),
            const _TypingIndicator(),
            const _ChatInputBar(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Crisis Banner
// ─────────────────────────────────────────────────────────────────────────────

class _CrisisBanner extends StatelessWidget {
  const _CrisisBanner();

  Future<void> _callNumber(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(EsSpacing.md),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.12),
        border: Border(
          bottom: BorderSide(
            color: Colors.redAccent.withOpacity(0.4),
            width: 1.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 24),
              const SizedBox(width: EsSpacing.sm),
              Expanded(
                child: Text(
                  S.of(context).crisisDisclaimer,
                  style: EsTypography.bodyMedium.copyWith(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: EsSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWebOrLarge = constraints.maxWidth > 500;
              final buttons = [
                _CrisisButton(
                  icon: Icons.emergency_outlined,
                  label: 'Emergencias (112)',
                  color: Colors.redAccent,
                  onPressed: () => _callNumber('112'),
                ),
                _CrisisButton(
                  icon: Icons.healing_outlined,
                  label: S.of(context).suicidePreventionLine,
                  color: Colors.orangeAccent[700] ?? Colors.orangeAccent,
                  onPressed: () => _callNumber('024'),
                ),
                _CrisisButton(
                  icon: Icons.favorite_outline,
                  label: 'T. Esperanza (717003717)',
                  color: Colors.blueAccent[700] ?? Colors.blueAccent,
                  onPressed: () => _callNumber('717003717'),
                ),
              ];

              if (isWebOrLarge) {
                return Row(
                  children: buttons
                      .map((b) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: EsSpacing.xs),
                              child: b,
                            ),
                          ))
                      .toList(),
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: buttons
                      .map((b) => Padding(
                            padding: const EdgeInsets.only(bottom: EsSpacing.xs),
                            child: b,
                          ))
                      .toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _CrisisButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _CrisisButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: EsTypography.bodyMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App Bar
// ─────────────────────────────────────────────────────────────────────────────

class _ChatHeader extends StatelessWidget {
  final String companionName;
  final bool showBack;
  const _ChatHeader({required this.companionName, required this.showBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: EsSpacing.md,
        vertical: EsSpacing.md,
      ),
      decoration: BoxDecoration(
        color: EsColors.backgroundDark,
        border: Border(
          bottom: BorderSide(
            color: EsColors.surfaceElevated.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (showBack) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: EsColors.textPrimaryDark, size: 20),
              onPressed: () => context.pop(),
            ),
            const SizedBox(width: EsSpacing.xs),
          ],
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [EsColors.primaryBlue, EsColors.neonCyan],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: EsColors.primaryBlue.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.graphic_eq, color: Colors.white, size: 22),
          ),
          const SizedBox(width: EsSpacing.md),
          // Name & Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  companionName,
                  style: EsTypography.headlineSmall.copyWith(
                    color: EsColors.textPrimaryDark,
                    fontSize: 20,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: EsColors.neonCyan,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      S.of(context).online,
                      style: EsTypography.bodySmall.copyWith(
                        color: EsColors.neonCyan,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Action button — abre el bottom sheet premium
          IconButton(
            icon: const Icon(Icons.info_outline,
                color: EsColors.textSecondaryDark),
            tooltip: S.of(context).companionInfo,
            onPressed: () => _showCompanionInfo(context, companionName),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Message List
// ─────────────────────────────────────────────────────────────────────────────

class _MessageList extends ConsumerWidget {
  const _MessageList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatProvider).messages;

    if (messages.isEmpty) {
      return const _EmptyChat();
    }

    // Constrain width on very wide screens (web desktop)
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView.builder(
          reverse: true,
          padding: const EdgeInsets.symmetric(
            horizontal: EsSpacing.md,
            vertical: EsSpacing.sm,
          ),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index];
            return ChatMessageBubble(
              text: msg.text,
              isMe: msg.isFromUser,
              isError: msg.isError,
              time: _formatTime(msg.timestamp),
            );
          },
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyChat extends StatelessWidget {
  const _EmptyChat();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  EsColors.primaryBlue.withOpacity(0.15),
                  EsColors.neonCyan.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              color: EsColors.primaryBlue,
              size: 48,
            ),
          ),
          const SizedBox(height: EsSpacing.lg),
          Text(
            S.of(context).startConversation,
            style: EsTypography.headlineMedium.copyWith(
              color: EsColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: EsSpacing.sm),
          Text(
            S.of(context).companionHereToListen,
            style: EsTypography.bodyMedium.copyWith(
              color: EsColors.textSecondaryDark,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Typing Indicator
// ─────────────────────────────────────────────────────────────────────────────

class _TypingIndicator extends ConsumerWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTyping = ref.watch(chatProvider).isTyping;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: isTyping
              ? Padding(
                  key: const ValueKey('typing'),
                  padding: const EdgeInsets.only(
                      left: EsSpacing.lg, bottom: EsSpacing.xs),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: EsColors.surfaceDark,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                          bottomLeft: Radius.circular(4),
                        ),
                        border: Border.all(
                            color: EsColors.neonCyan.withOpacity(0.3)),
                      ),
                      child: const _BouncingDots(),
                    ),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('not_typing')),
        ),
      ),
    );
  }
}

class _BouncingDots extends StatefulWidget {
  const _BouncingDots();
  @override
  State<_BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<_BouncingDots>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      )..repeat(reverse: true),
    );
    _animations = _controllers
        .asMap()
        .entries
        .map((e) => Tween<double>(begin: 0, end: -6).animate(
              CurvedAnimation(
                parent: e.value,
                curve: Interval(e.key * 0.2, 1.0, curve: Curves.easeInOut),
              ),
            ))
        .toList();

    // Stagger start
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 160), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (context, child) => Transform.translate(
            offset: Offset(0, _animations[i].value),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: EsColors.primaryBlue,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chat Input Bar
// ─────────────────────────────────────────────────────────────────────────────

class _ChatInputBar extends ConsumerStatefulWidget {
  const _ChatInputBar();

  @override
  ConsumerState<_ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends ConsumerState<_ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      final billing = ref.read(billingProvider).valueOrNull ?? const BillingEntity();
      if (!billing.canSendMessage) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).dailyLimitReached),
              backgroundColor: EsColors.warning,
              action: SnackBarAction(
                label: 'Premium',
                textColor: Colors.white,
                onPressed: () => context.push(RouteNames.paywall),
              ),
            ),
          );
        }
        return;
      }

      _controller.clear();
      _focusNode.requestFocus();
      await ref.read(chatProvider.notifier).sendMessage(text);
      
      try {
        await ref.read(billingProvider.notifier).incrementMessagesUsed();
      } catch (_) {
        // Silently swallow billing increment errors to avoid blocking the chat
      }
    } catch (_) {
      // General safety fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTyping = ref.watch(chatProvider).isTyping;
    final billing = ref.watch(billingProvider).valueOrNull ?? const BillingEntity();
    final canSend = billing.canSendMessage;

    final hintText = isTyping
        ? S.of(context).waitingForResponse
        : (!canSend
            ? S.of(context).dailyLimitReached
            : S.of(context).typeAMessage);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: EsSpacing.md,
            vertical: EsSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: EsColors.backgroundDark,
            border: Border(
              top: BorderSide(
                color: EsColors.surfaceElevated.withOpacity(0.5),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: !isTyping && canSend,
                  style: EsTypography.bodyMedium.copyWith(
                    color: EsColors.textPrimaryDark,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: EsTypography.bodyMedium
                        .copyWith(color: !canSend ? EsColors.warning : EsColors.textSecondaryDark),
                    filled: true,
                    fillColor: EsColors.surfaceDark,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: EsSpacing.md,
                      vertical: EsSpacing.sm,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: EsColors.primaryBlue.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                  ),
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
              const SizedBox(width: EsSpacing.sm),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: (isTyping || !canSend)
                      ? EsColors.surfaceElevated
                      : EsColors.primaryBlue,
                  shape: BoxShape.circle,
                  boxShadow: (isTyping || !canSend)
                      ? null
                      : [
                          BoxShadow(
                            color: EsColors.primaryBlue.withOpacity(0.4),
                            blurRadius: 8,
                          ),
                        ],
                ),
                child: IconButton(
                  icon: Icon(
                    isTyping
                        ? Icons.hourglass_top
                        : (!canSend ? Icons.lock_outline : Icons.send_rounded),
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: (isTyping || !canSend) ? null : _handleSend,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Companion Info Bottom Sheet — Premium
// ─────────────────────────────────────────────────────────────────────────────

/// Muestra el bottom sheet al pulsar el botón (i) en el header.
/// UI tonta: no contiene lógica de negocio, solo presentación.
///
/// NOTAS DE PLATAFORMA:
/// - screenH se lee del contexto EXTERIOR: el contexto del builder del
///   showModalBottomSheet vive en el Overlay y su MediaQuery no tiene las
///   dimensiones correctas en Android.
/// - backgroundColor usa el color real (NO transparent): en Android,
///   múltiples capas de transparencia apiladas causan un bug de composición
///   de GPU donde el contenido del sheet aparece completamente negro.
///   El sistema Android gestiona correctamente un color sólido + shape.
void _showCompanionInfo(BuildContext context, String companionName) {
  final screenH = MediaQuery.sizeOf(context).height;
  final screenW = MediaQuery.sizeOf(context).width;

  if (screenW >= 600) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 480,
            maxHeight: 650,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: _CompanionInfoContent(
                companionName: companionName,
                isDialog: true,
              ),
            ),
          ),
        ),
      ),
    );
  } else {
    final sheetH = screenH > 100 ? min(screenH * 0.76, 640.0) : 540.0;
    showModalBottomSheet(
      context: context,
      backgroundColor: EsColors.backgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: sheetH,
        child: _CompanionInfoContent(companionName: companionName),
      ),
    );
  }
}

// _CompanionInfoSheet eliminada: la lógica de altura se resolvió
// directamente en _showCompanionInfo usando el contexto externo.

class _CompanionInfoContent extends StatelessWidget {
  final String companionName;
  final bool isDialog;
  const _CompanionInfoContent({
    required this.companionName,
    this.isDialog = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: EsColors.backgroundDark,
        borderRadius: isDialog
            ? BorderRadius.circular(28)
            : const BorderRadius.vertical(top: Radius.circular(28)),
        // FIX ANDROID: Border() con colores distintos por lado + borderRadius
        // lanza "A borderRadius can only be given on borders with uniform colors"
        // en Android → el widget se renderiza negro. Border.all() es uniforme
        // y compatible con borderRadius en todas las plataformas.
        border: Border.all(
          color: EsColors.primaryBlue.withValues(alpha: 0.20),
          width: 1,
        ),
        // Sutil glow superior / periférico
        boxShadow: [
          BoxShadow(
            color: EsColors.primaryBlue.withValues(alpha: 0.12),
            blurRadius: 40,
            spreadRadius: -4,
            offset: isDialog ? const Offset(0, 0) : const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle pill or Close button ──
          if (isDialog)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.close, color: EsColors.textSecondaryDark),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            )
          else ...[
            const SizedBox(height: EsSpacing.md),
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: EsColors.textSecondaryDark.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: EsSpacing.xl),
          ],

          // ── Scrollable Content ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: EsSpacing.lg,
                right: EsSpacing.lg,
                bottom: EsSpacing.lg,
                top: 0,
              ),
              child: Column(
                children: [
                  // ── Avatar con aura animada ──
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Aura exterior difuminada
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: EsColors.neonCyan.withValues(alpha: 0.20),
                                blurRadius: 32,
                                spreadRadius: 8,
                              ),
                              BoxShadow(
                                color: EsColors.primaryBlue.withValues(alpha: 0.25),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        // Avatar
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [EsColors.primaryBlue, EsColors.neonCyan],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.graphic_eq,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                        // Indicador online
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: EsColors.neonCyan,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: EsColors.backgroundDark,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: EsColors.neonCyan.withValues(alpha: 0.5),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: EsSpacing.md),

                  // ── Nombre y tipo ──
                  Text(
                    companionName,
                    style: EsTypography.displayMedium.copyWith(
                      color: EsColors.textPrimaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: EsSpacing.sm),
                  Text(
                    S.of(context).empathicCompanion,
                    style: EsTypography.bodyMedium.copyWith(
                      color: EsColors.textSecondaryDark,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: EsSpacing.md),

                  // ── Badges de identidad ──
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _IdentityBadge(
                        icon: Icons.verified,
                        label: 'IA Verificada',
                        color: EsColors.primaryBlue,
                      ),
                      SizedBox(width: EsSpacing.sm),
                      _IdentityBadge(
                        icon: Icons.lock_outline,
                        label: 'Privado',
                        color: EsColors.neonCyan,
                      ),
                      SizedBox(width: EsSpacing.sm),
                      _IdentityBadge(
                        icon: Icons.psychology_alt_outlined,
                        label: 'GPT-4o',
                        color: Color(0xFF9B6DFF),
                      ),
                    ],
                  ),
                  const SizedBox(height: EsSpacing.xl),

                  // ── Sección: Capacidades ──
                  _SectionLabel(label: S.of(context).capabilitiesLabel),
                  const SizedBox(height: EsSpacing.sm),
                  _InfoFeatureRow(
                    icon: Icons.memory,
                    iconColor: EsColors.primaryBlue,
                    title: S.of(context).voiceMemoryMore,
                    description: S.of(context).memoryCapability,
                  ),
                  const SizedBox(height: EsSpacing.sm),
                  _InfoFeatureRow(
                    icon: Icons.favorite_border,
                    iconColor: const Color(0xFFFF6B9D),
                    title: S.of(context).emotionalSupportTitle,
                    description: S.of(context).emotionalSupportDesc,
                  ),
                  const SizedBox(height: EsSpacing.sm),
                  _InfoFeatureRow(
                    icon: Icons.notifications_active_outlined,
                    iconColor: EsColors.neonCyan,
                    title: 'Proactividad',
                    description: S.of(context).proactiveCapability,
                  ),
                  const SizedBox(height: EsSpacing.sm),
                  _InfoFeatureRow(
                    icon: Icons.lock_outline,
                    iconColor: const Color(0xFF10B981),
                    title: 'Privacidad',
                    description: S.of(context).privacyCapability,
                  ),
                  const SizedBox(height: EsSpacing.xl),

                  // ── Disclaimer Ético (importante para Play Store) ──
                  Container(
                    padding: const EdgeInsets.all(EsSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Colors.amber.withValues(alpha: 0.8),
                          size: 20,
                        ),
                        const SizedBox(width: EsSpacing.sm),
                        Expanded(
                          child: Text(
                            S.of(context).ethicalDisclaimer,
                            style: EsTypography.bodySmall.copyWith(
                              color: EsColors.textSecondaryDark,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: EsSpacing.lg),

                  // ── Botón Legal ──
                  TextButton.icon(
                    onPressed: () {
                      if (isDialog) Navigator.pop(context); // Cierra popup
                      context.push(RouteNames.legal);
                    },
                    icon: const Icon(Icons.gavel_outlined, size: 16),
                    label: Text(S.of(context).legalEthicalNotices),
                    style: TextButton.styleFrom(),
                  ),
                  const SizedBox(height: EsSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets premium ─────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [EsColors.primaryBlue, EsColors.neonCyan],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: EsSpacing.sm),
        Text(
          label.toUpperCase(),
          style: EsTypography.bodySmall.copyWith(
            color: EsColors.textSecondaryDark,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _IdentityBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _IdentityBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: EsTypography.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoFeatureRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _InfoFeatureRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(EsSpacing.md),
      decoration: BoxDecoration(
        color: EsColors.surfaceDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: EsSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: EsTypography.headlineSmall.copyWith(
                    color: EsColors.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: EsTypography.bodySmall.copyWith(
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LegalButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            colors: [
              EsColors.primaryBlue.withValues(alpha: 0.15),
              EsColors.neonCyan.withValues(alpha: 0.08),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          border: Border.all(
            color: EsColors.neonCyan.withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: EsColors.primaryBlue.withValues(alpha: 0.10),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.gavel_outlined,
              color: EsColors.neonCyan,
              size: 18,
            ),
            const SizedBox(width: EsSpacing.sm),
            Text(
              S.of(context).legalEthicalNotices,
              style: EsTypography.labelLarge.copyWith(
                color: EsColors.textPrimaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: EsSpacing.xs),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: EsColors.textSecondaryDark.withValues(alpha: 0.5),
              size: 13,
            ),
          ],
        ),
      ),
    );
  }
}
