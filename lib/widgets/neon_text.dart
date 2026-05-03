import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

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
    return Text(
      text,
      style: TextStyle(
        color: AppColors.primary,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: 1.5,
        shadows: [
          Shadow(color: AppColors.primary.withOpacity(0.8), blurRadius: 12),
          Shadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 24),
        ],
      ),
    );
  }
}
