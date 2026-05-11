import 'package:flutter/material.dart';
import '../../../core/constants/es_colors.dart';
import '../../../core/constants/es_spacing.dart';
import '../../../core/constants/es_typography.dart';

enum EsButtonVariant { primary, secondary, ghost, danger }

/// EchoSoul primary button atom.
/// - UI is completely dumb: no logic, no providers.
/// - Supports: loading state, disabled, leading icon.
class EsButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final EsButtonVariant variant;
  final bool isLoading;
  final IconData? leadingIcon;
  final double? width;
  final bool hasGlow;

  const EsButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = EsButtonVariant.primary,
    this.isLoading = false,
    this.leadingIcon,
    this.width,
    this.hasGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    return AnimatedOpacity(
      opacity: isDisabled ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        width: width ?? double.infinity,
        decoration: hasGlow && !isDisabled && variant == EsButtonVariant.primary
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: EsColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              )
            : null,
        child: _buildButton(),
      ),
    );
  }

  Widget _buildButton() {
    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        else if (leadingIcon != null) ...[
          Icon(leadingIcon, size: 18),
          const SizedBox(width: EsSpacing.sm),
        ],
        if (!isLoading)
          Text(label, style: EsTypography.labelLarge),
      ],
    );

    return switch (variant) {
      EsButtonVariant.primary => FilledButton(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: EsColors.primaryBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0, // We use BoxShadow instead
          ),
          child: content,
        ),
      EsButtonVariant.secondary => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: EsColors.neonCyan,
            side: const BorderSide(color: EsColors.neonCyan),
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: content,
        ),
      EsButtonVariant.ghost => TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: EsColors.neonCyan,
            minimumSize: const Size(double.infinity, 52),
          ),
          child: content,
        ),
      EsButtonVariant.danger => FilledButton(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: EsColors.distress,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: content,
        ),
    };
  }
}
