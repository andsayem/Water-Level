import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// Hebrew, Arabic, Persian and Urdu letters.
final _rtlScript = RegExp('[֐-ࣿ]');

class NeonText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;

  const NeonText({
    super.key,
    required this.text,
    this.fontSize = 20,
    this.fontWeight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    final glowStrength = AppColors.isDark ? 0.6 : 0.2;
    return Text(
      text,
      // Readings like "-2.6°" must stay left-to-right even in Arabic, Persian
      // or Urdu, otherwise the minus sign jumps to the other end.
      textDirection: _rtlScript.hasMatch(text) ? null : TextDirection.ltr,
      style: TextStyle(
        color: AppColors.primary,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: 1.5,
        shadows: [
          Shadow(
            color: AppColors.primary.withValues(alpha: glowStrength),
            blurRadius: 12,
          ),
          Shadow(
            color: AppColors.primary.withValues(alpha: glowStrength * 0.6),
            blurRadius: 24,
          ),
        ],
      ),
    );
  }
}
