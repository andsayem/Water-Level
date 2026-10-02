import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/level_provider.dart';
import '../utils/app_colors.dart';
import '../utils/strings.dart';
import '../widgets/neon_text.dart';
import '../widgets/tool_scaffold.dart';
import '../widgets/ui_kit.dart';

class ProtractorScreen extends StatefulWidget {
  const ProtractorScreen({super.key});

  @override
  State<ProtractorScreen> createState() => _ProtractorScreenState();
}

class _ProtractorScreenState extends State<ProtractorScreen> {
  bool _held = false;
  double _heldAngle = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LevelProvider>();

    // Magnitude from the true inclination (correct in any direction), sign
    // from whichever axis is tilted the most.
    final sign = provider.dominantAngle < 0 ? -1.0 : 1.0;
    final liveAngle = sign * min(provider.inclination, 90.0);
    final angle = _held ? _heldAngle : liveAngle;

    return ToolScaffold(
      title: tr('Protractor'),
      subtitle: tr(
        'Lay the phone against the slope, then tap Hold to freeze the reading.',
      ),
      action: GlowIconButton(
        icon: Icons.percent_rounded,
        tooltip: tr('Degrees'),
        onTap: provider.toggleUnit,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1.2,
                child: CustomPaint(
                  painter: _ProtractorPainter(
                    angle: angle,
                    color: AppColors.primary,
                    trackColor: AppColors.textTertiary,
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: NeonText(
                      text: provider.formatAngle(angle),
                      fontSize: 34,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ToolActionButton(
            label: _held ? tr('HELD — Tap to resume') : tr('HOLD'),
            active: _held,
            onTap: () => setState(() {
              if (!_held) _heldAngle = liveAngle;
              _held = !_held;
            }),
          ),
        ],
      ),
    );
  }
}

class _ProtractorPainter extends CustomPainter {
  final double angle;
  final Color color;
  final Color trackColor;

  _ProtractorPainter({
    required this.angle,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Leave the bottom fifth free for the reading below the pivot.
    final center = Offset(size.width / 2, size.height * 0.78);
    final radius = min(size.width / 2, size.height * 0.78) - 12;

    final arcPaint = Paint()
      ..color = trackColor.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      arcPaint,
    );

    final tickPaint = Paint()
      ..color = trackColor
      ..strokeWidth = 2;
    final labelStyle = TextStyle(color: trackColor, fontSize: 11);

    for (int deg = -90; deg <= 90; deg += 10) {
      final rad = (deg - 90) * pi / 180;
      final isMajor = deg % 30 == 0;
      final outer = Offset(
        center.dx + radius * cos(rad),
        center.dy + radius * sin(rad),
      );
      final inner = Offset(
        center.dx + (radius - (isMajor ? 14 : 8)) * cos(rad),
        center.dy + (radius - (isMajor ? 14 : 8)) * sin(rad),
      );
      canvas.drawLine(inner, outer, tickPaint);

      if (isMajor) {
        final labelPos = Offset(
          center.dx + (radius - 30) * cos(rad),
          center.dy + (radius - 30) * sin(rad),
        );
        final tp = TextPainter(
          text: TextSpan(text: '${deg.abs()}°', style: labelStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, labelPos - Offset(tp.width / 2, tp.height / 2));
      }
    }

    // Needle
    final clamped = angle.clamp(-90.0, 90.0);
    final needleRad = (clamped - 90) * pi / 180;
    final needleEnd = Offset(
      center.dx + (radius - 20) * cos(needleRad),
      center.dy + (radius - 20) * sin(needleRad),
    );
    final needlePaint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, needleEnd, needlePaint);
    canvas.drawCircle(center, 7, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _ProtractorPainter oldDelegate) {
    return oldDelegate.angle != angle ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor;
  }
}
