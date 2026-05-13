import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/es_colors.dart';
import '../../../../core/constants/es_spacing.dart';
import '../../../../core/constants/es_typography.dart';
import '../../../../core/utils/es_platform.dart';
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
          // Action button
          IconButton(
            icon: const Icon(Icons.info_outline,
                color: EsColors.textSecondaryDark),
            onPressed: () {
              // TODO: Mostrar info del companion
            },
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
