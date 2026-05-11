import 'package:flutter/material.dart';
import '../../../../core/constants/es_colors.dart';
import '../../../../core/constants/es_spacing.dart';
import '../../../../core/constants/es_typography.dart';

class ChatMessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String time;

  const ChatMessageBubble({
    super.key,
    required this.text,
    required this.isMe,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: EsSpacing.md),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? EsColors.primaryBlue : EsColors.surfaceDark,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          border: isMe ? null : Border.all(color: EsColors.neonCyan.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: EsSpacing.md, vertical: EsSpacing.sm),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: EsTypography.bodyMedium.copyWith(
                color: isMe ? Colors.white : EsColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: EsSpacing.xs),
            Text(
              time,
              style: EsTypography.caption.copyWith(
                color: isMe ? Colors.white70 : EsColors.textSecondaryDark,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
