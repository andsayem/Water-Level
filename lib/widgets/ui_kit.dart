import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/level_provider.dart';
import '../utils/app_colors.dart';
import 'neon_text.dart';

extension AppSettingsWatch on BuildContext {
  /// Rebuilds the caller when the theme or language changes, but not on
  /// every sensor sample (which [LevelProvider] publishes ~50 times a second).
  void watchAppSettings() => select<LevelProvider, (bool, String)>(
    (p) => (p.isDarkTheme, p.languageCode),
  );
}

/// Screen background: the theme colour with two soft accent glows and a
/// faint measuring grid, giving every page the same "instrument" feel.
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: AppColors.background),
      child: CustomPaint(
        painter: _BackgroundPainter(
          accent: AppColors.primary,
          isDark: AppColors.isDark,
        ),
        child: child,
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final Color accent;
  final bool isDark;

  _BackgroundPainter({required this.accent, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final glowAlpha = isDark ? 0.10 : 0.08;
    void glow(Offset center, double radius) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              accent.withValues(alpha: glowAlpha),
              accent.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }

    glow(Offset(size.width * 0.9, size.height * 0.08), size.width * 0.7);
    glow(Offset(size.width * 0.05, size.height * 0.75), size.width * 0.6);

    final grid = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.025)
      ..strokeWidth = 1;
    const step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter old) =>
      old.accent != accent || old.isDark != isDark;
}

/// Rounded "glass" surface used for cards and panels.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final bool highlight;
  final VoidCallback? onTap;
  final double radius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.highlight = false,
    this.onTap,
    this.radius = 22,
  });

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: highlight
              ? [
                  AppColors.primary.withValues(alpha: 0.22),
                  AppColors.cardGradient.last,
                ]
              : AppColors.cardGradient,
        ),
        border: Border.all(
          color: highlight
              ? AppColors.primary.withValues(alpha: 0.8)
              : AppColors.primary.withValues(alpha: 0.16),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: highlight ? 0.18 : 0.06),
            blurRadius: 22,
          ),
          if (!AppColors.isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return card;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: card,
    );
  }
}

/// Square icon button with a soft glow, used in headers.
class GlowIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? tooltip;

  const GlowIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.onLongPress,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.card,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.15),
              blurRadius: 10,
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

/// Page header: optional back button, neon title with an optional subtitle,
/// and trailing actions.
class ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final List<Widget> actions;
  final Widget? leading;

  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.actions = const [],
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final lead =
        leading ??
        (showBack
            ? GlowIconButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.of(context).maybePop(),
              )
            : null);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          if (lead != null) ...[lead, const SizedBox(width: 12)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: NeonText(text: title, fontSize: 22),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                      letterSpacing: 0.4,
                    ),
                  ),
              ],
            ),
          ),
          for (final action in actions) ...[const SizedBox(width: 10), action],
        ],
      ),
    );
  }
}

/// Small uppercase label above a group of cards.
class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pill showing whether the device is level, e.g. "LEVEL" / "TILTED 2.4°".
class LevelStatusPill extends StatelessWidget {
  final bool isLevel;
  final String label;

  const LevelStatusPill({
    super.key,
    required this.isLevel,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final color = isLevel ? AppColors.primary : Colors.orangeAccent;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: color.withValues(alpha: 0.14),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLevel ? Icons.check_circle_rounded : Icons.screen_rotation_alt,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Converts the larger of two tilt angles into a single "how far off" value.
double totalTilt(double x, double y) {
  // Angle between the phone's normal and vertical, approximated well for
  // the small angles a level is used at.
  return sqrt(x * x + y * y);
}
