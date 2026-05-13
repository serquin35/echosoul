import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A wrapper widget that provides hover effects and pointer cursor.
/// Useful for Desktop/Web versions of EchoSoul.
class EsInteractive extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double hoverScale;
  final double hoverOpacity;
  final Duration duration;

  const EsInteractive({
    super.key,
    required this.child,
    this.onTap,
    this.hoverScale = 1.0, // Set to 1.02 or similar for scale effect
    this.hoverOpacity = 0.8,
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  State<EsInteractive> createState() => _EsInteractiveState();
}

class _EsInteractiveState extends State<EsInteractive> {
  bool _isHovered = false;

  void _handleHover(bool isHovered) {
    if (widget.onTap != null) {
      setState(() {
        _isHovered = isHovered;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isClickable = widget.onTap != null;

    return MouseRegion(
      cursor: isClickable ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? widget.hoverScale : 1.0,
          duration: widget.duration,
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: (_isHovered ? widget.hoverOpacity : 1.0).clamp(0.0, 1.0),
            duration: widget.duration,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
