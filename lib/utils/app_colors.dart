import 'package:flutter/material.dart';

class AppColors {
  /// Whether the app is currently in dark mode. Set by the theme controller.
  static bool isDark = true;

  /// Brand accent. Darker in light mode so it stays visible on pale surfaces.
  static Color get primary =>
      isDark ? const Color(0xFFB7FF00) : const Color(0xFF4E9E00);

  static Color get secondary =>
      isDark ? const Color(0xFF8DFF00) : const Color(0xFF6BBF00);

  static const glow = Color(0xAA99FF00);
  static const glass = Color(0x22FFFFFF);

  /// Surface / scaffold background.
  static Color get background =>
      isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF3F5F8);

  /// Card / elevated surface background.
  static Color get card => isDark ? const Color(0xFF1B1B1B) : const Color(0xFFFFFFFF);

  /// Secondary surface (dialogs, text fields, etc).
  static Color get surface =>
      isDark ? const Color(0xFF232323) : const Color(0xFFE9EDF2);

  /// Primary body text color.
  static Color get textPrimary =>
      isDark ? const Color(0xFFFFFFFF) : const Color(0xFF14171C);

  /// Secondary / muted body text color.
  static Color get textSecondary =>
      isDark ? const Color(0xFFFFFFFF).withValues(alpha: 0.7) : const Color(0xFF5A636F);

  /// Tertiary / hint text color.
  static Color get textTertiary =>
      isDark ? const Color(0xFFFFFFFF).withValues(alpha: 0.38) : const Color(0xFF98A0AB);

  /// Gradient used by cards / top bars / tool tiles.
  static List<Color> get cardGradient =>
      isDark ? const [Color(0xFF232323), Color(0xFF121212)] : const [Color(0xFFFFFFFF), Color(0xFFE9EDF2)];

  /// Gradient used by the angle panel / highlighted boxes.
  static List<Color> get panelGradient =>
      isDark ? const [Color(0xFF222222), Color(0xFF121212)] : const [Color(0xFFFFFFFF), Color(0xFFE4E9EF)];

  /// Chassis gradient for the level instruments (kept dark in both modes).
  static const chassis = [Color(0xFF3A3A3A), Color(0xFF0A0A0A)];

  static final List<Color> themeColors = [
    const Color(0xFFB7FF00), // Neon Green
    const Color(0xFF00E5FF), // Cyan Blue
    const Color(0xFFFF2A93), // Hot Pink
    const Color(0xFFFF9100), // Bright Orange
  ];
}
