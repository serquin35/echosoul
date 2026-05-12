import 'package:flutter/material.dart';

/// Semantic color tokens for EchoSoul.
/// Never use raw Color() values outside this file.
abstract class EsColors {
  // ── Brand (Blue/Neon theme) ────────────────────────────
  static const primaryBlue  = Color(0xFF2E8DFF);
  static const neonCyan     = Color(0xFF00E5FF);
  static const deepBlue     = Color(0xFF0A1930);

  // ── Semantic / Emotional ───────────────────────────────
  static const calm         = Color(0xFF6BBBAE);
  static const energized    = Color(0xFFF4A261);
  static const distress     = Color(0xFFE76F51);
  static const neutral      = Color(0xFF8D99AE);

  // ── Backgrounds ────────────────────────────────────────
  static const backgroundDark  = Color(0xFF070B14);
  static const surfaceDark     = Color(0xFF121A2F);
  static const surfaceElevated = Color(0xFF1E2746);
  static const backgroundLight = Color(0xFFF0F4F8);
  static const surfaceLight    = Color(0xFFFFFFFF);

  // ── Text ───────────────────────────────────────────────
  static const textPrimaryDark   = Color(0xFFFFFFFF);
  static const textSecondaryDark = Color(0xFF8E9BB0);
  static const textPrimaryLight  = Color(0xFF0A1930);
  static const textSecondaryLight = Color(0xFF4A5568);

  // ── Utility ────────────────────────────────────────────
  static const success = Color(0xFF52B788);
  static const warning = Color(0xFFFFC300);
  static const error   = Color(0xFFE76F51);
  static const divider = Color(0xFF1E2746);
}
