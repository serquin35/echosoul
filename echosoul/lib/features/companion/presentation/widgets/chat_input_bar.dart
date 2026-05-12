import 'package:flutter/material.dart';
import '../../../../core/constants/es_colors.dart';
import '../../../../core/constants/es_spacing.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({super.key});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (_controller.text.trim().isEmpty) return;
    // TODO: Send message via provider
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: EsSpacing.md, vertical: EsSpacing.sm),
      decoration: BoxDecoration(
        color: EsColors.backgroundDark,
        border: Border(
          top: BorderSide(color: EsColors.surfaceDark, width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: EsColors.neonCyan),
              onPressed: () {
                // TODO: Attachments or quick actions
              },
            ),
            const SizedBox(width: EsSpacing.xs),
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: EsColors.textPrimaryDark),
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  hintStyle: const TextStyle(color: EsColors.textSecondaryDark),
                  filled: true,
                  fillColor: EsColors.surfaceDark,
                  contentPadding: const EdgeInsets.symmetric(horizontal: EsSpacing.md, vertical: EsSpacing.sm),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSend(),
              ),
            ),
            const SizedBox(width: EsSpacing.xs),
            Container(
              decoration: const BoxDecoration(
                color: EsColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _handleSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
