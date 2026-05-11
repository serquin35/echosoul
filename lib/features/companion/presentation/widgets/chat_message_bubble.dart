import 'package:flutter/material.dart';
import '../../../../core/constants/es_colors.dart';
import '../../../../core/constants/es_spacing.dart';
import '../../../../core/constants/es_typography.dart';

class ChatMessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String time;
  final bool isError;

  const ChatMessageBubble({
    super.key,
    required this.text,
    required this.isMe,
    required this.time,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isError
        ? EsColors.distress.withOpacity(0.15)
        : isMe
            ? EsColors.primaryBlue
            : EsColors.surfaceDark;

    final textColor = isMe ? Colors.white : EsColors.textPrimaryDark;
    final timeColor = isMe ? Colors.white60 : EsColors.textSecondaryDark;
    final borderColor = isError
        ? EsColors.distress.withOpacity(0.5)
        : isMe
            ? Colors.transparent
            : EsColors.neonCyan.withOpacity(0.25);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: EsSpacing.sm),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: isMe
              ? [
                  BoxShadow(
                    color: EsColors.primaryBlue.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: EsSpacing.md,
          vertical: EsSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (isError)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: EsColors.distress, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Error de conexión',
                    style: EsTypography.bodySmall.copyWith(
                      color: EsColors.distress,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            if (isError) const SizedBox(height: 4),
            Text(
              text,
              style: EsTypography.bodyMedium.copyWith(color: textColor),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: EsTypography.bodySmall.copyWith(
                color: timeColor,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
