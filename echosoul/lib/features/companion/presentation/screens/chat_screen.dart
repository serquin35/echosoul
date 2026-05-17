import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/es_colors.dart';
import '../../../../core/constants/es_spacing.dart';
import '../../../../core/constants/es_typography.dart';
import '../../../../core/utils/es_platform.dart';
import '../../../../core/router/route_names.dart';
import '../providers/chat_provider.dart';
import '../providers/companion_data_provider.dart';
import '../widgets/chat_message_bubble.dart';

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

  Future<void> _callEmergency() async {
    final uri = Uri.parse('tel:112'); // Or any general emergency number (024 in Spain for suicide prevention, 911, etc. using 112 as a universal default)
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: EsSpacing.md,
        vertical: EsSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.15),
        border: Border(
          bottom: BorderSide(
            color: Colors.redAccent.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              const SizedBox(width: EsSpacing.sm),
              Expanded(
                child: Text(
                  'No estás solo. Si estás en peligro, por favor busca ayuda inmediata.',
                  style: EsTypography.bodyMedium.copyWith(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: EsSpacing.sm),
          ElevatedButton.icon(
            onPressed: _callEmergency,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.phone),
            label: const Text('Llamar a Emergencias (112)'),
          ),
        ],
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
                      'En línea',
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
            tooltip: 'Info del compañero',
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
            'Comienza la conversación',
            style: EsTypography.headlineMedium.copyWith(
              color: EsColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: EsSpacing.sm),
          Text(
            'Tu compañero está aquí para escucharte.',
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
    _controller.clear();
    _focusNode.requestFocus();
    await ref.read(chatProvider.notifier).sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    final isTyping = ref.watch(chatProvider).isTyping;

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
                  enabled: !isTyping,
                  style: EsTypography.bodyMedium.copyWith(
                    color: EsColors.textPrimaryDark,
                  ),
                  decoration: InputDecoration(
                    hintText: isTyping
                        ? 'Esperando respuesta...'
                        : 'Escribe un mensaje…',
                    hintStyle: EsTypography.bodyMedium
                        .copyWith(color: EsColors.textSecondaryDark),
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
                  color: isTyping
                      ? EsColors.surfaceElevated
                      : EsColors.primaryBlue,
                  shape: BoxShape.circle,
                  boxShadow: isTyping
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
                    isTyping ? Icons.hourglass_top : Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: isTyping ? null : _handleSend,
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
  final sheetH  = screenH > 100 ? screenH * 0.82 : 580.0;

  showModalBottomSheet(
    context: context,
    // ─── FIX ANDROID ────────────────────────────────────────────────────
    // Colors.transparent causa un bug de composición GPU en Android donde
    // todo el sheet aparece negro. Usar el color real permite que Android
    // composite correctamente las capas del widget tree.
    backgroundColor: EsColors.backgroundDark,
    // shape en el nivel de showModalBottomSheet: recorte nativo de Android,
    // mucho más fiable que aplicar borderRadius dentro del árbol Flutter.
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    // ────────────────────────────────────────────────────────────────────
    isScrollControlled: true,
    builder: (_) => SizedBox(
      height: sheetH,
      child: _CompanionInfoContent(companionName: companionName),
    ),
  );
}

// _CompanionInfoSheet eliminada: la lógica de altura se resolvió
// directamente en _showCompanionInfo usando el contexto externo.

class _CompanionInfoContent extends StatelessWidget {
  final String companionName;
  const _CompanionInfoContent({
    required this.companionName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: EsColors.backgroundDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: EsColors.primaryBlue.withValues(alpha: 0.25),
            width: 1,
          ),
          left: BorderSide(
            color: EsColors.primaryBlue.withValues(alpha: 0.10),
            width: 1,
          ),
          right: BorderSide(
            color: EsColors.primaryBlue.withValues(alpha: 0.10),
            width: 1,
          ),
        ),
        // Sutil glow superior
        boxShadow: [
          BoxShadow(
            color: EsColors.primaryBlue.withValues(alpha: 0.12),
            blurRadius: 40,
            spreadRadius: -4,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: EsSpacing.lg,
          vertical: EsSpacing.md,
        ),
        child: Column(
          children: [
          // ── Handle pill ──
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
          const SizedBox(height: 4),
          Text(
            'Compañero Empático · EchoSoul',
            style: EsTypography.bodyMedium.copyWith(
              color: EsColors.neonCyan,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: EsSpacing.md),

          // ── Badges de identidad ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
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
          _SectionLabel(label: 'Capacidades'),
          const SizedBox(height: EsSpacing.sm),
          _InfoFeatureRow(
            icon: Icons.memory_outlined,
            iconColor: EsColors.primaryBlue,
            title: 'Memoria Adaptativa',
            description:
                'Recuerda tus sueños, miedos y pasiones para ofrecerte un acompañamiento con contexto y profundidad real.',
          ),
          const SizedBox(height: EsSpacing.sm),
          _InfoFeatureRow(
            icon: Icons.favorite_border,
            iconColor: const Color(0xFFFF6B9D),
            title: 'Apoyo Emocional 24/7',
            description:
                'Siempre disponible, libre de juicios y enfocado en tu bienestar. Un espacio para expresarte sin filtros.',
          ),
          const SizedBox(height: EsSpacing.sm),
          _InfoFeatureRow(
            icon: Icons.notifications_active_outlined,
            iconColor: EsColors.neonCyan,
            title: 'Check-ins Proactivos',
            description:
                'Buenos días personalizados, recordatorios y llamadas de voz para acompañarte en tu rutina diaria.',
          ),
          const SizedBox(height: EsSpacing.sm),
          _InfoFeatureRow(
            icon: Icons.security_outlined,
            iconColor: const Color(0xFF10B981),
            title: 'Cifrado y Privacidad',
            description:
                'Tus conversaciones están protegidas con cifrado extremo a extremo. Nunca se venderán ni compartirán.',
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
                    '$companionName es una IA, no un profesional de salud mental. '
                    'No ofrece diagnósticos ni sustituye la terapia. '
                    'En una crisis, busca ayuda profesional real.',
                    style: EsTypography.bodySmall.copyWith(
                      color: Colors.amber.withValues(alpha: 0.85),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: EsSpacing.lg),

          // ── Botón Legal ──
          _LegalButton(
            onTap: () {
              Navigator.pop(context);
              context.push(RouteNames.legal);
            },
          ),
          const SizedBox(height: EsSpacing.lg),
        ],
        ),
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
              'Avisos Legales y Éticos',
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
